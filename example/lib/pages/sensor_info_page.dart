import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

import '../widgets/time_interval_picker.dart';

class SensorInfoPage extends StatefulWidget {
  final SensorId sensorId;

  const SensorInfoPage({super.key, required this.sensorId});

  @override
  State<SensorInfoPage> createState() => _SensorInfoPageState();
}

class _SensorInfoPageState extends State<SensorInfoPage> {
  @override
  Widget build(BuildContext context) {
    var sensorInfoWidget = FutureBuilder(
      future: Future.sync(() async {
        var sensorInfo = await SensorManager().getSensorInfo(widget.sensorId);
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
              const SizedBox(height: 10),
              MaterialButton(
                color: Colors.blue,
                shape: const StadiumBorder(),
                child: const Text("Update interval"),
                onPressed: () async {
                  var hasIntervalChanged = await updateSensorInterval(
                    context,
                    widget.sensorId,
                    sensorInfo.timeIntervalInMilliseconds,
                  );

                  if (hasIntervalChanged) {
                    setState(() {});
                  }
                },
              ),
            ],
          );
        }

        return const Text(
          "Loading sensor information ...",
          style: TextStyle(color: Colors.grey),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensing Plugin Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              widget.sensorId.name,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            sensorInfoWidget,
          ],
        ),
      ),
    );
  }
}

Future<bool> updateSensorInterval(
  BuildContext context,
  SensorId sensorId,
  int timeIntervalInMilliseconds,
) async {
  var currentDateTime = DateTime.fromMillisecondsSinceEpoch(
    timeIntervalInMilliseconds,
    isUtc: true,
  );

  var hasIntervalChanged = false;
  await DatePicker.showPicker(
    context,
    pickerModel: TimeIntervalPicker(
      startTime: currentDateTime,
    ),
    onConfirm: (newDateTime) async {
      if (currentDateTime.isAtSameMomentAs(newDateTime)) {
        return;
      }

      await SensorManager().changeSensorTimeInterval(
        sensorId,
        newDateTime.millisecondsSinceEpoch,
      );

      hasIntervalChanged = true;
    },
  );

  return hasIntervalChanged;
}
