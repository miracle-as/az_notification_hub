package com.tangrainc.azure_notification_hub

import com.google.firebase.messaging.RemoteMessage

fun RemoteMessage.toMap(): HashMap<String, Any?> {
    val messageMap = HashMap<String, Any?>()
    val dataMap = HashMap<String, Any>()
    val notification = this.notification
    val data = this.data

    this.messageId?.also { messageMap["id"] = it as Any }

    notification?.title?.also { messageMap["title"] = it as Any }
    notification?.body?.also { messageMap["body"] = it as Any }

    for (item in data) {
        dataMap[item.key] = item.value
    }
    messageMap["data"] = dataMap

    return messageMap
}