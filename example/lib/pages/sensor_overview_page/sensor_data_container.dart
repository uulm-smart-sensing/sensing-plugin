import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

class SensorDataContainer extends StatefulWidget {
  final Stream<SensorData> stream;
  final int displayedDecimalPlaces;

  const SensorDataContainer({
    super.key,
    required this.stream,
    required this.displayedDecimalPlaces,
  });

  @override
  State<SensorDataContainer> createState() => _SensorDataContainerState();
}

class _SensorDataContainerState extends State<SensorDataContainer> {
  var _data = <double>[];
  DateTime? _timestamp;
  DateTime? _lastTimestamp;

  @override
  void initState() {
    widget.stream.listen((sensorData) {
      setState(() {
        _data = sensorData.data.whereType<double>().toList();
        _lastTimestamp = _timestamp;
        _timestamp = DateTime.fromMicrosecondsSinceEpoch(
          sensorData.timestampInMicroseconds,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var timestampInformation = [
      Text(
        _timestamp != null
            ? "Timestamp: ${_timestamp.toString()}"
            : "Waiting to receive data",
      ),
    ];

    if (_lastTimestamp != null && _timestamp != null) {
      var timeDifference = _timestamp!.difference(_lastTimestamp!);
      timestampInformation.add(
        Text(
          "Last timestamp was ${timeDifference.inMilliseconds} ms ago",
        ),
      );
    }

    return Column(
      children: [
        ...timestampInformation,
        const SizedBox(height: 4),
        formatData(_data),
      ],
    );
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
                value.toStringAsFixed(widget.displayedDecimalPlaces),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
}
