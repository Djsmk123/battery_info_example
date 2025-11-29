import Flutter
import UIKit

/// Platform Channel implementation for battery information on iOS.
///
/// This plugin provides battery information using the traditional
/// Flutter platform channel approach (MethodChannel).
public class BatteryInfoExamplePlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "battery_info_example",
            binaryMessenger: registrar.messenger()
        )
        let instance = BatteryInfoExamplePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "getBatteryLevel":
            let batteryLevel = getBatteryLevel()
            if batteryLevel >= 0 {
                result(batteryLevel)
            } else {
                result(FlutterError(
                    code: "UNAVAILABLE",
                    message: "Battery level not available.",
                    details: nil
                ))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Gets the current battery level as a percentage (0-100).
    ///
    /// - Returns: Battery level percentage, or -1 if unavailable
    private func getBatteryLevel() -> Int {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true

        if device.batteryState == .unknown {
            return -1
        } else {
            return Int(device.batteryLevel * 100)
        }
    }
}
