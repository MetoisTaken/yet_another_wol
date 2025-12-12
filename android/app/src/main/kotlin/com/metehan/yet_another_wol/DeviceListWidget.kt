package com.metehan.yet_another_wol

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class DeviceListWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Determine what to show.
                // The Flutter side saves a JSON string under 'devices_data' key.
                val devicesJson = widgetData.getString("devices_data", null)
                val textToShow = if (devicesJson != null) {
                   "Tap to open app" // Placeholder for now, later we can parse JSON
                } else {
                   "No data"
                }

                setTextViewText(R.id.widget_title, textToShow)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
