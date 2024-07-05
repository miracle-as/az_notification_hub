package com.tangrainc.azure_notification_hub

import androidx.lifecycle.LiveData
import com.google.firebase.messaging.RemoteMessage

class AzRemoteMessageLiveData : LiveData<RemoteMessage>() {
    companion object {
        private var instance: AzRemoteMessageLiveData? = null

        fun getInstance(): AzRemoteMessageLiveData {
            if (instance == null) {
                instance = AzRemoteMessageLiveData()
            }

            return instance!!;
        }
    }

    fun postRemoteMessage(remoteMessage: RemoteMessage) {
        postValue(remoteMessage)
    }
}