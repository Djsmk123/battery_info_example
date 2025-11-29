# Battery Info Example

A cross-platform Flutter plugin demonstrating two approaches for accessing native battery information on **Android** and **iOS**:

- **Platform Channels** (MethodChannel) - Standard Flutter approach
- **Native FFI** - Direct FFI approach:
  - **Android**: JNI (Java Native Interface) with jnigen
  - **iOS**: FFI (Foreign Function Interface) with ffigen

The app includes a live performance benchmark comparing both approaches on each platform.

## Demo
<!-- <video width="320" height="240" src="https://github.com/Djsmk123/battery_info_example/raw/refs/heads/main/assets/demo.mov" controls></video> -->
https://github.com/Djsmk123/battery_info_example/blob/main/assets/demo.mov

## Getting Started

### Prerequisites
- Flutter 3.3+
- **Android**: Android SDK & NDK
- **iOS**: Xcode with iOS SDK

### Setup

1. **Install dependencies**:
```bash
cd battery_info_example
flutter pub get
```

2. **Generate Android JNI bindings** (for Android):
```bash
export ANDROID_SDK_ROOT=/path/to/your/android/sdk
dart run jnigen --config jnigen.yaml
```

3. **Generate iOS FFI bindings** (for iOS):
```bash
dart run ffigen --config ffigen.yaml
```

### Run the Example

```bash
cd example
# Run on Android
flutter run -d <android-device>

# Run on iOS
flutter run -d <ios-device>
```

## Project Structure

### Dart Layer
- `lib/battery_info_example.dart` - Platform Channel API (works on both platforms)
- `lib/battery_info_jni_wrapper.dart` - Android JNI wrapper
- `lib/battery_info_ffi_wrapper.dart` - iOS FFI wrapper
- `lib/src/generated/` - Auto-generated bindings (jnigen + ffigen)

### Android Native
- `android/.../BatteryInfoExamplePlugin.kt` - Platform Channel handler
- `android/.../BatteryInfoJni.kt` - JNI implementation

### iOS Native
- `ios/Classes/BatteryInfoExamplePlugin.swift` - Platform Channel handler
- `ios/Classes/BatteryInfoFfi.h/.m` - FFI C/Objective-C implementation

### Example App
- `example/lib/main.dart` - Cross-platform benchmark UI

## Approach Comparison

### Platform Channels vs Native FFI

|                    | Platform Channels      | Native FFI (JNI/FFI)        |
|--------------------|------------------------|----------------------------|
| **Setup**          | Easy                   | Complex                    |
| **Code Generation**| No                     | Yes (jnigen/ffigen)        |
| **Performance**    | Good (~3-5ms)          | Excellent (~1-2ms)         |
| **Platforms**      | All (unified code)     | Platform-specific wrappers |
| **Memory Mgmt**    | Automatic              | Manual (Android JNI)       |
| **Maintenance**    | Easy                   | Moderate                   |

### When to Use Each

**Platform Channels** (Recommended for most plugins):
- ✅ Easy to implement and maintain
- ✅ Works across all platforms with single codebase
- ✅ Sufficient performance for most use cases
- ✅ Better error handling and debugging

**Native FFI** (For specific use cases):
- ✅ Maximum performance (1.5-3x faster for simple operations)
- ✅ Wrapping existing native libraries
- ✅ Direct access to platform APIs without serialization
- ⚠️ Requires platform-specific code and maintenance
- ⚠️ More complex setup with code generation

## Features Demonstrated

- ✨ Battery level percentage
- ✨ Charging status detection
- ✨ Battery temperature (Android only)
- ✨ Live performance benchmarking
- ✨ Cross-platform compatibility
- ✨ Platform-specific optimizations

## Technical Details

### Android Architecture
```
Platform Channel: Dart → MethodChannel → Kotlin → BatteryManager
JNI: Dart → dart:ffi → jnigen bindings → Kotlin → BatteryManager
```

### iOS Architecture
```
Platform Channel: Dart → MethodChannel → Swift → UIDevice
FFI: Dart → dart:ffi → ffigen bindings → C/Objective-C → UIDevice
```

## Contributing

This project serves as both a functional plugin and an educational example for Flutter developers learning about platform integration patterns.
