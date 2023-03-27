import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import '../../widgets/sensor_widgets/sensor_widget.dart';

class SensorOverviewPage extends StatefulWidget {
  const SensorOverviewPage({super.key});

  @override
  State<SensorOverviewPage> createState() => _SensorOverviewPageState();
}

class _SensorOverviewPageState extends State<SensorOverviewPage> {
  bool showUnavailableSensors = true;

  @override
  Widget build(BuildContext context) {
    var checkBox = CheckboxListTile(
      title: const Text("Show unavailable sensors"),
      value: showUnavailableSensors,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (isChecked) {
        setState(() {
          showUnavailableSensors = isChecked!;
        });
      },
    );

    var sensorWidgets = SensorId.values.map(
      (sensorId) => SensorWidget(
        sensorId: sensorId,
        showWhenUnavailable: showUnavailableSensors,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensing Plugin Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            checkBox,
            ...sensorWidgets,
          ],
        ),
      ),
    );
  }
}
