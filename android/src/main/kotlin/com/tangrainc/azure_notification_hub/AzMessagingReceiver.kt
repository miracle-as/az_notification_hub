package com.tangrainc.azure_notification_hub

import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.firebase.messaging.RemoteMessage

class AzMessagingReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("FANH", "message received")
        val remoteMessage = intent?.extras?.let { RemoteMessage(it) }
        if (remoteMessage != null) {
            if (isApplicationInForeground(context)) {
                AzRemoteMessageLiveData.getInstance().postRemoteMessage(remoteMessage)
            } else {
                AzRemoteMessageBackgroundWorker.enqueueWork(context, remoteMessage)
            }
        }
    }

    private fun isApplicationInForeground(context: Context): Boolean {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        // This only shows processes for the current android app.
        val appProcesses = activityManager.runningAppProcesses
            ?: // If no processes are running, appProcesses are null, not an empty list.
            // The user's app is definitely not in the foreground if no processes are running.
            return false
        for (process in appProcesses) {
            // Importance is IMPORTANCE_SERVICE (not IMPORTANCE_FOREGROUND)
            //  - when app was terminated, or
            //  - when app is in the background, or
            //  - when screen is locked, including when app was in foreground.
            if (process.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                // App is in the foreground
                return true
            }
        }
        return false
    }
}