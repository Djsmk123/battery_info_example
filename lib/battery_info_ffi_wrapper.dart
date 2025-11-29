import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:developer';

import 'src/generated/battery_info_ffi_bindings.dart';

/// Wrapper for iOS battery information using FFI.
///
/// This demonstrates direct FFI access to iOS UIDevice APIs via C functions
/// without using Flutter's platform channels.
///
/// Usage:
/// ```dart
/// final batteryInfo = BatteryInfoFfiWrapper();
/// final level = batteryInfo.getBatteryLevel();
/// print('Battery: $level%');
/// ```
class BatteryInfoFfiWrapper {
  static BatteryInfoFfi? _bindings;

  /// Gets the FFI bindings instance.
  ///
  /// Loads the native library on first access.
  BatteryInfoFfi get _ffi {
    if (_bindings == null) {
      if (!Platform.isIOS) {
        throw UnsupportedError('BatteryInfoFfiWrapper only supports iOS');
      }

      // On iOS, the library is statically linked into the app
      final dylib = ffi.DynamicLibrary.process();
      _bindings = BatteryInfoFfi(dylib);
    }
    return _bindings!;
  }

  /// Gets the current battery level as a percentage (0-100).
  ///
  /// This method uses FFI to directly call C functions that wrap
  /// iOS UIDevice battery APIs.
  ///
  /// Returns -1 if battery level is unavailable.
  int getBatteryLevel() {
    try {
      return _ffi.battery_info_get_level();
    } catch (e) {
      log('Error getting battery level via FFI: $e');
      return -1;
    }
  }

  /// Checks if the device is currently charging.
  ///
  /// Returns true if the device is currently charging, false otherwise.
  bool isCharging() {
    try {
      return _ffi.battery_info_is_charging() == 1;
    } catch (e) {
      log('Error checking charging status via FFI: $e');
      return false;
    }
  }

  /// Gets the battery state.
  ///
  /// Returns:
  /// - 0: Unknown
  /// - 1: Unplugged
  /// - 2: Charging
  /// - 3: Full
  int getBatteryState() {
    try {
      return _ffi.battery_info_get_state();
    } catch (e) {
      log('Error getting battery state via FFI: $e');
      return 0;
    }
  }

  /// Gets a human-readable battery state string.
  String getBatteryStateString() {
    final state = getBatteryState();
    switch (state) {
      case 1:
        return 'Unplugged';
      case 2:
        return 'Charging';
      case 3:
        return 'Full';
      default:
        return 'Unknown';
    }
  }
}
