import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

class SensorInfoPage extends StatelessWidget {
  final SensorId sensorId;

  const SensorInfoPage({super.key, required this.sensorId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sensing Plugin Demo'),
        ),
        body: Text("$sensorId"),
      );
}
