import 'package:flutter/material.dart';
import 'pages/sensor_overview_page/sensor_overview_page.dart';

void main() => runApp(const SensingPluginDemoApp());

class SensingPluginDemoApp extends StatelessWidget {
  const SensingPluginDemoApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SensorOverviewPage(),
      );
}
