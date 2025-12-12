package com.metehan.yet_another_wol

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import android.app.PendingIntent
import android.net.Uri

class DeviceListWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // Set up the collection
            val serviceIntent = Intent(context, DeviceListWidgetService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
            
            views.setRemoteAdapter(R.id.device_list_view, serviceIntent)
            views.setEmptyView(R.id.device_list_view, R.id.empty_view)

            // Set up the pending intent template for items
            // Set up the pending intent template for items
            val backgroundIntent = Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java)
            backgroundIntent.action = "es.antonborri.home_widget.action.BACKGROUND"

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                backgroundIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.device_list_view, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.device_list_view)
        }
    }
}
