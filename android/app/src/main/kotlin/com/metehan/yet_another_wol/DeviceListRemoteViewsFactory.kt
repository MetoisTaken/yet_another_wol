package com.metehan.yet_another_wol

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class DeviceListRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private var devices = JSONArray()

    override fun onCreate() {
        // Init
    }

    override fun onDataSetChanged() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val jsonString = widgetData.getString("devices_data", "[]")
        try {
            devices = JSONArray(jsonString)
        } catch (e: Exception) {
            devices = JSONArray()
        }
    }

    override fun onDestroy() {
        // Clear
    }

    override fun getCount(): Int {
        return devices.length()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        try {
            val device = devices.getJSONObject(position)
            val alias = device.getString("alias")
            val mac = device.getString("mac")
            val id = device.getString("id") // Required for unique ID
            val port = device.optInt("port", 9)

            views.setTextViewText(R.id.device_alias, alias)
            views.setTextViewText(R.id.device_mac, mac)

            // FillInIntent for click
            val fillInIntent = Intent()
            // We construct a specific URI for this item
            val uri = android.net.Uri.parse("wol://wake?mac=$mac&port=$port&alias=$alias")
            fillInIntent.data = uri
            
            views.setOnClickFillInIntent(R.id.widget_item_container, fillInIntent)

        } catch (e: Exception) {
            e.printStackTrace()
        }
        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
