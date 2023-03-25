import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin_example/sensor_widget.dart';

class SensorContainer extends StatefulWidget {
  const SensorContainer({super.key});

  @override
  State<SensorContainer> createState() => _SensorContainerState();
}

class _SensorContainerState extends State<SensorContainer> {
  bool showUnavailableSensors = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("Show unavailable sensors"),
          value: showUnavailableSensors,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (isChecked) {
            setState(() {
              showUnavailableSensors = isChecked!;
            });
          },
        ),
        ...SensorId.values.map(
          (sensorId) => SensorWidget(
            sensorId: sensorId,
            showWhenUnavailable: showUnavailableSensors,
          ),
        ),
      ],
    );
  }
}
