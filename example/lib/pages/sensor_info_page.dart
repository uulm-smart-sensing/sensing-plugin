import 'dart:convert';

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
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                sensorId.name,
                style: const TextStyle(fontSize: 16),
              ),
              const Padding(padding: EdgeInsets.only(top: 8.0)),
              getSensorInfoWidget(sensorId),
            ],
          ),
        ),
      );
}

FutureBuilder getSensorInfoWidget(SensorId sensorId) => FutureBuilder(
      future: Future.sync(() async {
        var sensorInfo = await SensorManager().getSensorInfo(sensorId);
        return jsonEncode(sensorInfo.encode());
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "An error occured while loading sensor information",
            style: TextStyle(color: Colors.red),
          );
        }

        if (snapshot.hasData) {
          var sensorInfo = SensorInfo.decode(jsonDecode(snapshot.data!));
          return Column(
            children: [
              Text("Unit: ${sensorInfo.unit.name}"),
              Text("Accuracy: ${sensorInfo.accuracy.name}"),
              Text("Interval: ${sensorInfo.timeIntervalInMilliseconds} ms"),
            ],
          );
        }

        return const Text(
          "Loading sensor information ...",
          style: TextStyle(color: Colors.grey),
        );
      },
    );
