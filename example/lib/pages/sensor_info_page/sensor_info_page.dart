import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

import 'sensor_info_widget.dart';

class SensorInfoPage extends StatefulWidget {
  final SensorId _sensorId;

  const SensorInfoPage({super.key, required SensorId sensorId})
      : _sensorId = sensorId;

  @override
  State<SensorInfoPage> createState() => _SensorInfoPageState();
}

class _SensorInfoPageState extends State<SensorInfoPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sensing Plugin Demo'),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                widget._sensorId.name,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              SensorInfoWidget(sensorId: widget._sensorId),
            ],
          ),
        ),
      );
}
