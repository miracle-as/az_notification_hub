package com.tangrainc.flutter_azure_notification_hub

import android.content.Context
import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationListener

class AzHubListener : NotificationListener {
    override fun onPushNotificationReceived(context: Context?, message: RemoteMessage?) {
        var x = message?.notification
        Log.d("AzNH", "message received!")
    }
}