#ifndef BatteryInfoFfi_h
#define BatteryInfoFfi_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Gets the current battery level as a percentage (0-100).
/// Returns -1 if battery level is unavailable.
int32_t battery_info_get_level(void);

/// Checks if the device is currently charging.
/// Returns 1 if charging, 0 if not charging or unknown.
int32_t battery_info_is_charging(void);

/// Gets the battery state.
/// Returns: 0 = unknown, 1 = unplugged, 2 = charging, 3 = full
int32_t battery_info_get_state(void);

#ifdef __cplusplus
}
#endif

#endif /* BatteryInfoFfi_h */
