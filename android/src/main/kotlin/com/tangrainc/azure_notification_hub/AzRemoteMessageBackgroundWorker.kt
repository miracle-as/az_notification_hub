package com.tangrainc.azure_notification_hub

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Parcel
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.firebase.messaging.RemoteMessage
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.FlutterCallbackInformation
import java.util.concurrent.atomic.AtomicBoolean


class AzRemoteMessageBackgroundWorker(private val context: Context, params: WorkerParameters) :
    Worker(context, params), MethodCallHandler {
    companion object {
        const val TAG = "FANH Worker"
        private val workerInited = AtomicBoolean(false)
        private var backgroundFlutterEngine: FlutterEngine? = null
        private var backgroundChannel: MethodChannel? = null

        fun enqueueWork(context: Context, remoteMessage: RemoteMessage) {
            val parcel = Parcel.obtain()
            remoteMessage.writeToParcel(parcel, 0)

            val data = Data.Builder()
                .putByteArray(
                    AzureNotificationHubPlugin.REMOTE_MESSAGE_BYTES_KEY,
                    parcel.marshall()
                )
                .build()

            val request = OneTimeWorkRequest.Builder(AzRemoteMessageBackgroundWorker::class.java)
                .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                .setInputData(data)
                .build()

            WorkManager.getInstance(context).enqueue(request)
        }
    }

    private val queue = ArrayDeque<Map<String, Any?>>()

    init {
        synchronized(workerInited) {
            if (backgroundFlutterEngine == null) {
                val callbackDispatcherHandle = context
                    .getSharedPreferences(
                        AzureNotificationHubPlugin.SHARED_PREFERENCES_KEY,
                        Context.MODE_PRIVATE
                    )
                    .getLong(AzureNotificationHubPlugin.CALLBACK_DISPATCHER_HANDLE_KEY, 0)

                if (callbackDispatcherHandle == 0L) {
                    Log.e(TAG, "Fatal: no callback registered")
                    return@synchronized
                }

                val loader = FlutterInjector.instance().flutterLoader()
                val mainHandler = Handler(Looper.getMainLooper())
                val myRunnable = Runnable {
                    loader.startInitialization(context)
                    loader.ensureInitializationCompleteAsync(
                        context,
                        null,
                        mainHandler
                    ) {
                        Log.i(TAG, "Creating background FlutterEngine instance.")
                        backgroundFlutterEngine = FlutterEngine(context)

                        // We need to create an instance of `FlutterEngine` before looking up the
                        // callback. If we don't, the callback cache won't be initialized and the
                        // lookup will fail.
                        val flutterCallback = FlutterCallbackInformation.lookupCallbackInformation(
                            callbackDispatcherHandle
                        )

                        if (flutterCallback == null) {
                            Log.e(TAG, "Failed to find registered callback")
                            return@ensureInitializationCompleteAsync
                        }

                        val executor = backgroundFlutterEngine!!.dartExecutor

                        backgroundChannel = MethodChannel(
                            executor,
                            "plugins.flutter.io/azure_notification_hub_background"
                        )
                        backgroundChannel!!.setMethodCallHandler(this)

                        val dartCallback = DartCallback(
                            context.assets,
                            loader.findAppBundlePath(),
                            flutterCallback
                        )

                        executor.executeDartCallback(dartCallback)
                    }
                }
                mainHandler.post(myRunnable)
            }
        }
    }

    override fun doWork(): Result {
        val callbackHandle = context
            .getSharedPreferences(
                AzureNotificationHubPlugin.SHARED_PREFERENCES_KEY,
                Context.MODE_PRIVATE
            )
            .getLong(AzureNotificationHubPlugin.CALLBACK_HANDLE_KEY, 0)
        val messageBytes =
            inputData.getByteArray(AzureNotificationHubPlugin.REMOTE_MESSAGE_BYTES_KEY)
        if (messageBytes != null) {
            val parcel = Parcel.obtain()
            try {
                parcel.unmarshall(messageBytes, 0, messageBytes.size)
                parcel.setDataPosition(0)

                val remoteMessage = RemoteMessage.CREATOR.createFromParcel(parcel)
                val dartMethodArgs: HashMap<String, Any> = hashMapOf(
                    "userCallbackHandle" to callbackHandle,
                    "message" to remoteMessage.toMap(),
                )
                synchronized(workerInited) {
                    if (!workerInited.get()) {
                        Log.i(TAG, "Worker not started, queueing message")
                        queue.add(dartMethodArgs)
                    } else {
                        Handler(context.mainLooper).post {
                            backgroundChannel!!.invokeMethod(
                                "AzRemoteMessageBackgroundWorker.onMessage",
                                dartMethodArgs
                            )
                        }
                    }
                }
            } finally {
                parcel.recycle()
            }
        }

        return Result.success()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "AzRemoteMessageBackgroundWorker.initialized" -> {
                synchronized(workerInited) {
                    while (queue.isNotEmpty()) {
                        backgroundChannel!!.invokeMethod(
                            "AzRemoteMessageBackgroundWorker.onMessage",
                            queue.removeFirst()
                        )
                    }
                    workerInited.set(true)
                }
            }

            else -> result.notImplemented()
        }
    }
}