package com.tangrainc.azure_notification_hub

import android.content.Context
import com.google.firebase.messaging.RemoteMessage
import com.microsoft.windowsazure.messaging.notificationhubs.NotificationListener

class AzHubListener : NotificationListener {
    override fun onPushNotificationReceived(context: Context?, message: RemoteMessage?) {
        // We do not handle anything here, since the message will be handled by the background service
    }
}