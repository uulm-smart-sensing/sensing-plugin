import 'package:flutter/material.dart';
import 'package:sensing_plugin_example/sensor_widgets/sensor_container.dart';

class SensorOverviewPage extends StatelessWidget {
  const SensorOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 16.0,
          ),
          child: SensorContainer(),
        );
  }
}
