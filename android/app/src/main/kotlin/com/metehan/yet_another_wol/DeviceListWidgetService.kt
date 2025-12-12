package com.metehan.yet_another_wol

import android.content.Intent
import android.widget.RemoteViewsService

class DeviceListWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return DeviceListRemoteViewsFactory(this.applicationContext, intent)
    }
}
