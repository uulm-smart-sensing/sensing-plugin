import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sensing_plugin/sensing_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isGyroAvailable;
  late bool _isGyroStarted;
  List<double?> _sensorData = List.filled(3, 0.0);
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    initGyroStatus();
  }

  Future<void> initGyroStatus() async {
    bool isGyroAvailable = await SensorManager().isSensorAvailable();

    if (!mounted) return;

    setState(() {
      _isGyroAvailable = isGyroAvailable;
    });

    if (isGyroAvailable) {
      final stream = await SensorManager().startTracking();
      _streamSubscription = stream.listen((sensorEvent) {
        setState(() {
          _sensorData = sensorEvent.data;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              Text('Gyro Available: $_isGyroAvailable\n'),
              Text(
                  'Gyro data: (${_sensorData[0]}, ${_sensorData[1]}, ${_sensorData[2]})'),
            ],
          )),
    );
  }
}
