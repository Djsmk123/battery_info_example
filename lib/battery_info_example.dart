import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class BatteryInfoExample {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery_info_example');

  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<int> getBatteryLevel() async {
    try {
      final int? result = await methodChannel.invokeMethod<int>('getBatteryLevel');
      if (result == null) {
        throw PlatformException(
          code: 'UNAVAILABLE',
          message: 'Battery level not available.',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }
}
