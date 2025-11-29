
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:battery_info_example/battery_info_example.dart';
import 'package:battery_info_example/battery_info_jni_wrapper.dart';
import 'package:battery_info_example/battery_info_ffi_wrapper.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Platform Channel approach
  int _batteryLevelPlatform = -1;
  String _batteryTimePlatform = '';

  // Native approach (JNI for Android, FFI for iOS)
  int _batteryLevelNative = -1;
  String _batteryTimeNative = '';
  bool _isChargingNative = false;
  int _temperatureNative = -1;

  final _batteryInfoPlugin = BatteryInfoExample();
  BatteryInfoJniWrapper? _batteryInfoJni;
  BatteryInfoFfiWrapper? _batteryInfoFfi;

  String _flutterVersion = "";
  String _nativeApproach = "";

  @override
  void initState() {
    super.initState();

    // Initialize platform-specific native wrapper
    if (Platform.isAndroid) {
      _batteryInfoJni = BatteryInfoJniWrapper();
      _nativeApproach = "JNI (Direct FFI)";
    } else if (Platform.isIOS) {
      _batteryInfoFfi = BatteryInfoFfiWrapper();
      _nativeApproach = "FFI (C Functions)";
    }

    _getBatteryLevelPlatform();
    _getBatteryLevelNative();
    _fetchFlutterVersion();
  }

  void _fetchFlutterVersion() async {
    try {
      setState(() {
        _flutterVersion = FlutterVersion.version??"";
      });
    } catch (e) {
      _flutterVersion = 'unknown';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _batteryInfoJni?.dispose();
    super.dispose();
  }

  Future<void> _getBatteryLevelPlatform() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final batteryLevel = await _batteryInfoPlugin.getBatteryLevel();
      final elapsed = stopwatch.elapsedMicroseconds;
      stopwatch.stop();
      setState(() {
        _batteryLevelPlatform = batteryLevel;
        _batteryTimePlatform = '$elapsed μs';
      });
    } catch (e) {
      setState(() {
        _batteryLevelPlatform = -1;
        _batteryTimePlatform = 'Error: $e';
      });
    }
  }

  Future<void> _getBatteryLevelNative() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      int batteryLevel = -1;
      bool isCharging = false;
      int temperature = -1;

      if (Platform.isAndroid && _batteryInfoJni != null) {
        batteryLevel = _batteryInfoJni!.getBatteryLevel();
        isCharging = _batteryInfoJni!.isCharging();
        temperature = _batteryInfoJni!.getTemperature();
      } else if (Platform.isIOS && _batteryInfoFfi != null) {
        batteryLevel = _batteryInfoFfi!.getBatteryLevel();
        isCharging = _batteryInfoFfi!.isCharging();
        temperature = -1; // Temperature not available via iOS FFI
      }

      final elapsed = stopwatch.elapsedMicroseconds;
      stopwatch.stop();
      setState(() {
        _batteryLevelNative = batteryLevel;
        _isChargingNative = isCharging;
        _temperatureNative = temperature;
        _batteryTimeNative = '$elapsed μs';
      });
    } catch (e) {
      setState(() {
        _batteryLevelNative = -1;
        _batteryTimeNative = 'Error: $e';
      });
    }
  }

  Future<void> _refreshBatteryInfo() async {
    await Future.wait([
      _getBatteryLevelPlatform(),
      _getBatteryLevelNative(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter: Platform Channel vs JNI'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Performance Benchmark',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              if (_flutterVersion.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Flutter $_flutterVersion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.blueGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),

              // Refresh Button
              ElevatedButton.icon(
                onPressed: _refreshBatteryInfo,
                icon: const Icon(Icons.refresh),
                label: const Text('Run Benchmark'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Platform Channel Section
              _buildSectionHeader(context, 'Platform Channel'),
              const SizedBox(height: 12),
              _buildResultCard(
                context,
                _batteryLevelPlatform >= 0 ? '$_batteryLevelPlatform%' : 'N/A',
                _batteryTimePlatform,
                Colors.blue,
              ),
              const SizedBox(height: 24),

              // Native Section (JNI for Android, FFI for iOS)
              _buildSectionHeader(context, _nativeApproach),
              const SizedBox(height: 12),
              _buildResultCard(
                context,
                _batteryLevelNative >= 0 ? '$_batteryLevelNative%' : 'N/A',
                _batteryTimeNative,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildNativeDetailsCard(context),
              const SizedBox(height: 24),

              // Performance Comparison
              _buildPerformanceComparison(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    String value,
    String time,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNativeDetailsCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(
                  _isChargingNative ? Icons.battery_charging_full : Icons.battery_std,
                  color: _isChargingNative ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  _isChargingNative ? 'Charging' : 'Not Charging',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (Platform.isAndroid)
              Column(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _temperatureNative >= 0 ? '$_temperatureNative°C' : 'N/A',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceComparison(BuildContext context) {
    final platformTime = int.tryParse(_batteryTimePlatform.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    final nativeTime = int.tryParse(_batteryTimeNative.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

    String speedup = '';
    String nativeLabel = Platform.isAndroid ? 'JNI' : 'FFI';
    if (platformTime > 0 && nativeTime > 0) {
      final ratio = (platformTime / nativeTime).toStringAsFixed(1);
      speedup = '${ratio}x faster';
    }

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Benchmark Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (speedup.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, color: Colors.orange.shade900),
                    const SizedBox(width: 8),
                    Text(
                      '$nativeLabel is $speedup',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Platform Channel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _batteryTimePlatform,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      nativeLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _batteryTimeNative,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
