#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BatteryInfoFfi.h"

/// FFI implementation for battery information on iOS.
///
/// These C functions can be called directly from Dart using dart:ffi
/// without the overhead of platform channels.

int32_t battery_info_get_level(void) {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        return -1;
    }

    float batteryLevel = device.batteryLevel;
    if (batteryLevel < 0) {
        return -1;
    }

    return (int32_t)(batteryLevel * 100);
}

int32_t battery_info_is_charging(void) {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    UIDeviceBatteryState state = device.batteryState;
    return (state == UIDeviceBatteryStateCharging ||
            state == UIDeviceBatteryStateFull) ? 1 : 0;
}

int32_t battery_info_get_state(void) {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    return (int32_t)device.batteryState;
}
