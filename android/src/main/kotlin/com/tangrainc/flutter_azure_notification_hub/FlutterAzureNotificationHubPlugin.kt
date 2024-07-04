package com.tangrainc.flutter_azure_notification_hub

import android.app.Application
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationHub

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterAzureNotificationHubPlugin */
class FlutterAzureNotificationHubPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var application: Application? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_azure_notification_hub")
    channel.setMethodCallHandler(this)
    application = flutterPluginBinding.applicationContext as Application
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "start" -> startHubConnection(result)
      else -> result.notImplemented()
    }
  }

  private fun startHubConnection(result: Result) {
    if (application == null) {
      return;
    }

    val metaData = application!!.packageManager.getApplicationInfo(
      application!!.packageName,
      PackageManager.GET_META_DATA).metaData

    NotificationHub.start(
      application,
      metaData.getString("NotificationHubName"),
      metaData.getString("NotificationHubConnectionString"))
    NotificationHub.setListener(AzHubListener())

    result.success(null)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    application = null
  }
}
