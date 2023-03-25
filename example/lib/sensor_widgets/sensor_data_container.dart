import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

class SensorDataContainer extends StatefulWidget {
  final Stream<SensorData> stream;

  const SensorDataContainer({super.key, required this.stream});

  @override
  State<SensorDataContainer> createState() => _SensorDataContainerState();
}

class _SensorDataContainerState extends State<SensorDataContainer> {
  var data = <double>[];
  Unit? unit;
  DateTime? timestamp;

  @override
  void initState() {
    widget.stream.listen((sensorData) {
      setState(() {
        data = sensorData.data.whereType<double>().toList();
        unit = sensorData.unit;
        timestamp = DateTime.fromMicrosecondsSinceEpoch(
            sensorData.timestampInMicroseconds);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Unit: ${unit ?? 'none'}"),
        Text("Timestamp: ${timestamp != null ? timestamp.toString() : 'none'}"),
        formatData(data),
      ],
    );
  }
}

Widget formatData(List<double> data) {
  var widgets = <Widget>[];
  while (data.isNotEmpty) {
    widgets.add(formatRow(data.take(3)));
    data.removeRange(0, min(3, data.length));
  }
  return Column(
    children: widgets,
  );
}

Widget formatRow(Iterable<double> data) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...data.map(
          (value) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              value.toStringAsFixed(3),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
