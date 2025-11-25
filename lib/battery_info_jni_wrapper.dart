import 'dart:developer';

import 'package:jni/jni.dart';
import 'src/generated/battery_info_jni.dart';

/// Wrapper for BatteryInfoJni using jnigen-generated bindings.
///
/// This demonstrates direct JNI access to Android APIs via dart:ffi
/// without using Flutter's platform channels.
///
/// Usage:
/// ```dart
/// final batteryInfo = BatteryInfoJniWrapper();
/// final level = batteryInfo.getBatteryLevel();
/// print('Battery: $level%');
/// batteryInfo.dispose(); // Clean up JNI resources
/// ```
class BatteryInfoJniWrapper {
  BatteryInfoJni? _jniInstance;

  /// Lazy initialization - creates the JNI instance on first use
  BatteryInfoJni get _instance {
    if (_jniInstance == null) {
      // Get the Android application context
      // The activity itself is a Context, so we can use it directly
      final activity = Jni.getCurrentActivity();

      // Convert JReference to JObject to pass to BatteryInfoJni constructor
      final activityObject = JObject.fromReference(activity);

      // Create the BatteryInfoJni instance with the activity context
      _jniInstance = BatteryInfoJni(activityObject);
    }
    return _jniInstance!;
  }

  /// Gets the current battery level as a percentage (0-100).
  ///
  /// This method uses JNI to directly call the Java BatteryInfoJni class,
  /// which wraps Android's BatteryManager API.
  ///
  /// Returns -1 if battery level is unavailable.
  int getBatteryLevel() {
    try {
      return _instance.getBatteryLevel();
    } catch (e) {
      log('Error getting battery level via JNI: $e');
      return -1;
    }
  }

  /// Checks if the device is currently charging.
  ///
  /// Returns true if the device is currently charging, false otherwise.
  bool isCharging() {
    try {
      return _instance.isCharging();
    } catch (e) {
      log('Error checking charging status via JNI: $e');
      return false;
    }
  }

  /// Gets battery temperature in tenths of a degree Celsius.
  ///
  /// Returns the temperature value or -1 if unavailable.
  int getTemperature() {
    try {
      return _instance.getTemperature();
    } catch (e) {
      log('Error getting temperature via JNI: $e');
      return -1;
    }
  }

  /// Releases JNI resources.
  ///
  /// Call this when you're done using the wrapper to free native resources.
  void dispose() {
    _jniInstance?.release();
    _jniInstance = null;
  }
}
