import 'package:flutter/material.dart';
import 'package:sensing_plugin_example/pages/sensor_overview_page.dart';

void main() => runApp(const SensingPluginDemoApp());

class SensingPluginDemoApp extends StatelessWidget {
  const SensingPluginDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SensorOverviewPage(),
    );
  }
}
