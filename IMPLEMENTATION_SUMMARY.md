# Battery Info Example - JNI vs Method Channel Implementation

## Summary

Successfully implemented a comprehensive comparison between **Platform Channels** and **JNI (Java Native Interface)** for both simple API calls and network requests in Flutter.

## What Was Built

### 1. Battery Information Access
- **Method Channel**: Traditional Flutter approach using Kotlin
- **JNI**: Direct native calls using jnigen-generated bindings

### 2. Network HTTP Requests (NEW)
- **Method Channel**: Uses Ktor HTTP client library in Kotlin
- **JNI**: Uses Java's HttpURLConnection
- Both support GET and POST requests

## Architecture

### Platform Channel Approach (Method Channel + Ktor)
```
Flutter Dart → Method Channel → Kotlin Code → Ktor HTTP Client → Android API
```

**Components:**
- `lib/battery_info_example.dart` - Dart API with method channel calls
- `android/.../BatteryInfoExamplePlugin.kt` - Kotlin plugin with Ktor integration
- Uses async/await with Kotlin coroutines

### JNI Approach (dart:ffi + jnigen)
```
Flutter Dart → dart:ffi → JNI Bridge → Java Code → Android API
```

**Components:**
- `lib/battery_info_jni_wrapper.dart` - Battery JNI wrapper
- `lib/network_jni_wrapper.dart` - Network JNI wrapper
- `android/.../BatteryInfoJni.java` - Java battery implementation
- `android/.../NetworkClient.java` - Java network implementation
- `lib/src/generated/battery_info_jni.dart` - Auto-generated JNI bindings

## Key Files Created/Modified

### Android Native Layer
1. **`android/build.gradle`**
   - Added Ktor dependencies (client-core, client-cio, content-negotiation)
   - Added Kotlin coroutines
   - Added Gson for JSON serialization

2. **`android/src/main/java/com/example/battery_info_example/NetworkClient.java`**
   - Java HTTP client using HttpURLConnection
   - Synchronous GET and POST methods
   - Required for JNI (jnigen needs Java source files)

3. **`android/src/main/kotlin/.../BatteryInfoExamplePlugin.kt`**
   - Added Ktor HTTP client initialization
   - Added `httpGet()` and `httpPost()` methods
   - Uses Kotlin coroutines for async operations

### Dart Layer
4. **`lib/network_jni_wrapper.dart`**
   - Wrapper for NetworkClient JNI bindings
   - Handles JString conversions
   - Provides Future-based API

5. **`lib/battery_info_example.dart`**
   - Added `httpGet()` and `httpPost()` methods
   - Method channel communication

6. **`example/lib/main.dart`**
   - Complete UI rewrite with comparison sections
   - Battery information comparison
   - HTTP GET request comparison
   - HTTP POST request comparison
   - Performance timing for all operations

### Configuration
7. **`jnigen.yaml`**
   - Updated to include NetworkClient class
   - Generates bindings for both BatteryInfoJni and NetworkClient

## Features

### Battery Info Test
- Compares latency of accessing BatteryManager API
- Shows execution time in microseconds (μs)
- Auto-loads on app startup

### HTTP GET Test
- Fetches data from jsonplaceholder.typicode.com/posts/1
- Compares Method Channel (Ktor) vs JNI (HttpURLConnection)
- Shows execution time in milliseconds (ms)
- Displays first 100 characters of response

### HTTP POST Test
- Posts JSON data to jsonplaceholder.typicode.com/posts
- Same comparison as GET
- Sends: `{"title": "Test", "body": "JNI vs Method Channel", "userId": 1}`

## Performance Considerations

### Method Channel (Ktor)
**Pros:**
- Modern async/await API with Kotlin coroutines
- Rich feature set (interceptors, content negotiation, etc.)
- Better error handling and timeouts
- Recommended by Flutter team

**Cons:**
- Additional serialization overhead (Dart ↔ Kotlin)
- Message passing through platform channels

### JNI (HttpURLConnection)
**Pros:**
- Direct native calls, lower latency for simple operations
- No serialization overhead for JNI layer
- Type-safe bindings via jnigen

**Cons:**
- More complex setup (requires jnigen)
- Synchronous operations (must use Future.microtask)
- Limited to Java APIs (jnigen can't parse Kotlin)
- Manual memory management (JString release)

## How to Run

1. **Generate JNI bindings** (if not already done):
   ```bash
   cd battery_info_example
   dart run jnigen --config jnigen.yaml
   ```

2. **Run the example app**:
   ```bash
   cd example
   flutter run
   ```

3. **Test the features**:
   - Battery info loads automatically
   - Tap "Test GET Request" to compare GET performance
   - Tap "Test POST Request" to compare POST performance

## Technical Notes

### Why Java Instead of Kotlin for JNI?
jnigen requires Java source files because it uses the Java Doclet API for analysis. It cannot parse Kotlin source code. This is documented in the BatteryInfoJni.java and NetworkClient.java files.

### JString Conversion
JNI methods return `JString` objects, not Dart Strings. The wrappers handle conversion:
```dart
final jUrl = url.toJString();           // Dart → JString
final jResult = _instance.get0(jUrl);   // JNI call
final result = jResult.toDartString();  // JString → Dart
jUrl.release();                          // Clean up
```

### Network Requests
- Both implementations use real HTTP requests (not mocked)
- Method Channel uses Ktor (modern Kotlin HTTP client)
- JNI uses HttpURLConnection (Java standard library)
- Timeouts set to 10 seconds for both

## Dependencies Added

```gradle
// Ktor client for networking
implementation("io.ktor:ktor-client-core:2.3.7")
implementation("io.ktor:ktor-client-cio:2.3.7")
implementation("io.ktor:ktor-client-content-negotiation:2.3.7")
implementation("io.ktor:ktor-serialization-gson:2.3.7")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

// Gson
implementation("com.google.code.gson:gson:2.10.1")
```

## Future Enhancements

Possible improvements:
- Add authentication examples
- Test with larger payloads
- Add WebSocket comparison
- Implement parallel request tests
- Add error injection for testing error handling
- Profile memory usage comparison
