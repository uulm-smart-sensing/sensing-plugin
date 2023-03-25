import 'package:flutter/material.dart';
import 'package:sensing_plugin_example/pages/sensor_overview_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sensing Plugin Demo'),
        ),
        body: const SensorOverviewPage(),
      ),
    );
  }
}
