# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter plugin demonstrating two approaches for accessing native platform APIs on both Android and iOS:
1. **Platform Channels** (MethodChannel) - Standard Flutter approach
2. **Native FFI** - Direct FFI approach:
   - **Android**: JNI (Java Native Interface) using jnigen
   - **iOS**: FFI (Foreign Function Interface) using ffigen

The plugin provides battery information and serves as a cross-platform performance comparison benchmark.

## Common Commands

### Development Setup
```bash
# Install dependencies
flutter pub get

# Generate Android JNI bindings (required after modifying Java/Kotlin classes in jnigen.yaml)
# Set ANDROID_SDK_ROOT environment variable first
export ANDROID_SDK_ROOT=/path/to/your/android/sdk
dart run jnigen --config jnigen.yaml

# Generate iOS FFI bindings (required after modifying C headers)
dart run ffigen --config ffigen.yaml
```

### Building and Running
```bash
# Run the example app
cd example
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests (requires connected device/emulator)
cd example
flutter test integration_test/plugin_integration_test.dart
```

## Code Architecture

### Dual Implementation Pattern

This plugin implements the same functionality using two different approaches on both platforms, allowing direct performance comparison:

**Platform Channel Path (Android & iOS):**
```
Dart (lib/battery_info_example.dart)
  → MethodChannel
  → Platform-specific plugin:
    - Android: Kotlin (BatteryInfoExamplePlugin.kt) → BatteryManager API
    - iOS: Swift (BatteryInfoExamplePlugin.swift) → UIDevice API
```

**Native FFI Path:**

Android (JNI):
```
Dart (lib/battery_info_jni_wrapper.dart)
  → dart:ffi
  → jnigen-generated bindings (lib/src/generated/battery_info_jni.dart)
  → Kotlin Helper (BatteryInfoJni.kt)
  → Android BatteryManager API
```

iOS (FFI):
```
Dart (lib/battery_info_ffi_wrapper.dart)
  → dart:ffi
  → ffigen-generated bindings (lib/src/generated/battery_info_ffi_bindings.dart)
  → C Functions (BatteryInfoFfi.m)
  → iOS UIDevice API
```

### Key Architectural Points

1. **Platform Detection**: The example app uses `Platform.isAndroid` and `Platform.isIOS` to determine which native FFI wrapper to use (JNI for Android, FFI for iOS). Platform Channels work on both platforms automatically.

2. **Android - jnigen Limitations**: jnigen uses Java Doclet API and cannot parse Kotlin source files. If adding new JNI classes, they must be written in Java or have Java source files available. See `jnigen.yaml` for configured classes.

3. **Android - Context Management**: JNI classes need Android Context. The wrapper obtains it via `Jni.getCurrentActivity()` and converts it to JObject before passing to native constructors.

4. **Android - Resource Management**: JNI wrappers must call `.release()` on JNI objects to prevent memory leaks. The example app properly disposes of the `BatteryInfoJniWrapper` in `dispose()`.

5. **iOS - Static Linking**: iOS FFI functions are statically linked into the app using `DynamicLibrary.process()`. No dynamic library loading is needed.

6. **iOS - Objective-C/C**: iOS FFI implementation uses Objective-C (.m) for accessing UIDevice APIs, exposed via C headers (.h) for dart:ffi compatibility.

7. **Generated Code**: The `lib/src/generated/` directory contains auto-generated bindings:
   - `battery_info_jni.dart` - Android JNI bindings (regenerate with `dart run jnigen`)
   - `battery_info_ffi_bindings.dart` - iOS FFI bindings (regenerate with `dart run ffigen`)
   Never manually edit these files.

## File Structure

### Plugin Core (Dart)
- `lib/battery_info_example.dart` - Platform Channel API using MethodChannel (works on both Android & iOS)
- `lib/battery_info_jni_wrapper.dart` - Android JNI wrapper via dart:ffi
- `lib/battery_info_ffi_wrapper.dart` - iOS FFI wrapper via dart:ffi

### Android Native Layer
- `android/src/main/kotlin/.../BatteryInfoExamplePlugin.kt` - Platform Channel handler
- `android/src/main/kotlin/.../BatteryInfoJni.kt` - JNI helper for battery info
- `android/build.gradle` - Android dependencies and build configuration

### iOS Native Layer
- `ios/Classes/BatteryInfoExamplePlugin.swift` - Platform Channel handler
- `ios/Classes/BatteryInfoFfi.h` - C header defining FFI functions
- `ios/Classes/BatteryInfoFfi.m` - Objective-C implementation accessing UIDevice
- `ios/battery_info_example.podspec` - CocoaPods specification

### Generated Bindings
- `lib/src/generated/battery_info_jni.dart` - Auto-generated Android JNI bindings (do not edit)
- `lib/src/generated/battery_info_ffi_bindings.dart` - Auto-generated iOS FFI bindings (do not edit)

### Example App
- `example/lib/main.dart` - Cross-platform benchmark UI comparing both approaches with performance metrics

### Configuration
- `jnigen.yaml` - Android JNI code generator configuration
- `ffigen.yaml` - iOS FFI bindings generator configuration
- `pubspec.yaml` - Flutter plugin dependencies including `jni` and `ffigen` packages

## Development Workflow

### Adding New Android JNI Functionality

1. Create/modify Kotlin class in `android/src/main/kotlin/`
2. Add class to `classes:` list in `jnigen.yaml`
3. Regenerate bindings: `dart run jnigen --config jnigen.yaml`
4. Create/update Dart wrapper in `lib/battery_info_jni_wrapper.dart`
5. Update example app to demonstrate new functionality

### Adding New iOS FFI Functionality

1. Add C function declarations to `ios/Classes/BatteryInfoFfi.h`
2. Implement functions in `ios/Classes/BatteryInfoFfi.m` using Objective-C
3. Regenerate bindings: `dart run ffigen --config ffigen.yaml`
4. Create/update Dart wrapper in `lib/battery_info_ffi_wrapper.dart`
5. Update example app with platform detection (`Platform.isIOS`)

### Adding Platform Channel Functionality

1. Add method handlers in platform-specific plugins:
   - Android: `BatteryInfoExamplePlugin.kt`
   - iOS: `BatteryInfoExamplePlugin.swift`
2. Add corresponding Dart method in `lib/battery_info_example.dart`
3. Update example app (works automatically on both platforms)

## Performance Considerations

**Native FFI (JNI/FFI):**
- Typically shows lower latency (~1.5-3x faster) for simple operations due to direct FFI calls
- Requires platform-specific wrappers and code generation
- Android JNI requires manual memory management (release() calls)
- iOS FFI uses static linking, no dynamic library management needed

**Platform Channels:**
- Have serialization overhead (encoding/decoding across language boundaries)
- Easier to implement and maintain
- Single codebase works across all platforms
- Recommended approach for most Flutter plugins

**When to Use Each:**
- Use Platform Channels for most plugins (ease of maintenance)
- Use native FFI when wrapping existing native libraries or when every microsecond matters

## Important Notes

**Android:**
- **Android SDK**: The `jnigen.yaml` file contains a hardcoded `sdk_root` path. Update this for your local environment or use the `ANDROID_SDK_ROOT` environment variable.
- **jnigen Version**: Keep `jni` and `jnigen` package versions in sync (currently 0.11.0).
- **API Level**: Currently targets Android API 34. Update `android_sdk_config.versions` in `jnigen.yaml` if targeting different API levels.

**iOS:**
- **Xcode Required**: Building for iOS requires Xcode and iOS SDK installed.
- **Minimum iOS Version**: Currently targets iOS 12.0 (see `battery_info_example.podspec`).
- **CocoaPods**: The iOS plugin is distributed via CocoaPods. Run `pod install` in the example/ios directory if needed.

**Cross-Platform:**
- The example app uses `Platform.isAndroid` and `Platform.isIOS` to select the appropriate native wrapper.
- Generated bindings for both platforms are in `lib/src/generated/` - regenerate after changing native code.
- Platform Channels work identically on both platforms without platform detection.
