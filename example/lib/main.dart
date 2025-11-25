
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:battery_info_example/battery_info_example.dart';
import 'package:battery_info_example/battery_info_jni_wrapper.dart';
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

  // JNI approach
  int _batteryLevelJni = -1;
  String _batteryTimeJni = '';
  bool _isChargingJni = false;
  int _temperatureJni = -1;

  final _batteryInfoPlugin = BatteryInfoExample();
  final _batteryInfoJni = BatteryInfoJniWrapper();

  String _flutterVersion = "";

  @override
  void initState() {
    super.initState();
    _getBatteryLevelPlatform();
    _getBatteryLevelJni();
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
    _batteryInfoJni.dispose();
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

  Future<void> _getBatteryLevelJni() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final batteryLevel = _batteryInfoJni.getBatteryLevel();
      final isCharging = _batteryInfoJni.isCharging();
      final temperature = _batteryInfoJni.getTemperature();
      final elapsed = stopwatch.elapsedMicroseconds;
      stopwatch.stop();
      setState(() {
        _batteryLevelJni = batteryLevel;
        _isChargingJni = isCharging;
        _temperatureJni = temperature;
        _batteryTimeJni = '$elapsed μs';
      });
    } catch (e) {
      setState(() {
        _batteryLevelJni = -1;
        _batteryTimeJni = 'Error: $e';
      });
    }
  }

  Future<void> _refreshBatteryInfo() async {
    await Future.wait([
      _getBatteryLevelPlatform(),
      _getBatteryLevelJni(),
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

              // JNI Section
              _buildSectionHeader(context, 'JNI (Direct FFI)'),
              const SizedBox(height: 12),
              _buildResultCard(
                context,
                _batteryLevelJni >= 0 ? '$_batteryLevelJni%' : 'N/A',
                _batteryTimeJni,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildJniDetailsCard(context),
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

  Widget _buildJniDetailsCard(BuildContext context) {
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
                  _isChargingJni ? Icons.battery_charging_full : Icons.battery_std,
                  color: _isChargingJni ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  _isChargingJni ? 'Charging' : 'Not Charging',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.thermostat,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  _temperatureJni >= 0 ? '$_temperatureJni°C' : 'N/A',
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
    final jniTime = int.tryParse(_batteryTimeJni.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

    String speedup = '';
    if (platformTime > 0 && jniTime > 0) {
      final ratio = (platformTime / jniTime).toStringAsFixed(1);
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
                      'JNI is $speedup',
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
                      'JNI',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _batteryTimeJni,
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
