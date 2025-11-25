# Battery Info Example

A Flutter plugin showing two ways to get Android battery info:

- **Platform Channels** (MethodChannel)
- **JNI with jnigen**

## Demo
<!-- <video width="320" height="240" src="https://github.com/Djsmk123/battery_info_example/raw/refs/heads/main/assets/demo.mov" controls></video> -->
https://github.com/Djsmk123/battery_info_example/blob/main/assets/demo.mov
## Getting Started



Prerequisites:
- Flutter 3.3+
- Android SDK & NDK

Clone, install dependencies, and generate JNI bindings:
```bash
cd battery_info_example
flutter pub get
export ANDROID_SDK_ROOT=your_android_sdk_path
dart run jnigen --config jnigen.yaml
```

Run the example:
```bash
cd example
flutter run
```

## Main Files

- `lib/battery_info_example_method_channel.dart`: Platform channel code
- `lib/battery_info_jni_wrapper.dart`: JNI wrapper
- `android/.../BatteryInfoExamplePlugin.kt`: Platform channel handler
- `android/.../BatteryInfoJni.kt`: JNI helper
- `lib/src/generated/`: jnigen bindings

## Comparison

|         | Platform Channel | JNI (jnigen)   |
|---------|-----------------|---------------|
| Setup   | Easy            | Harder        |
| Codegen | No              | Yes           |
| Speed   | Good            | Fastest       |

**Use Platform Channels** for most plugins.<br>
**Use JNI** if wrapping existing Java/Kotlin code or when performance is critical.
