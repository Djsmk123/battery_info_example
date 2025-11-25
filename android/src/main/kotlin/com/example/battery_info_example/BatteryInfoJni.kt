package com.example.battery_info_example

import android.content.Context
import android.os.BatteryManager
import android.os.Build

/**
 * Battery information helper class for JNI access.
 *
 * This class provides battery-related information using Android's BatteryManager API.
 * It will be accessed from Dart via JNI using jnigen-generated bindings.
 *
 * Note: For jnigen compatibility, you may need to keep a Java version of this class
 * since jnigen uses the Java Doclet API which cannot parse Kotlin source files.
 */
class BatteryInfoJni(private val context: Context) {

    /**
     * Get current battery level as percentage (0-100).
     * @return Battery level percentage, or -1 if unavailable
     */
    fun getBatteryLevel(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
        } else {
            -1
        }
    }

    /**
     * Check if device is currently charging.
     * @return true if charging, false otherwise
     */
    fun isCharging(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            batteryManager?.isCharging ?: false
        } else {
            false
        }
    }

    /**
     * Get battery temperature in tenths of a degree Celsius.
     * @return Temperature or -1 if unavailable
     */
    fun getTemperature(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW) ?: -1
        } else {
            -1
        }
    }
}
