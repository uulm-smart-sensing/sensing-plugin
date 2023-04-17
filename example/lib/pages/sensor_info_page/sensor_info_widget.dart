import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

import 'time_interval_picker.dart';

const unitToStringRepresentation = {
  Unit.metersPerSecondSquared: "m/s^2",
  Unit.gravitationalForce: "G",
  Unit.radiansPerSecond: "rad/s",
  Unit.degreesPerSecond: "deg/s",
  Unit.microTeslas: "µT",
  Unit.radians: "rad",
  Unit.degrees: "deg",
  Unit.hectoPascal: "hPa",
  Unit.kiloPascal: "kPa",
  Unit.bar: "Bar",
  Unit.celsius: "°C",
  Unit.fahrenheit: "°F",
  Unit.kelvin: "K",
  Unit.unitless: "",
};

class SensorInfoWidget extends StatefulWidget {
  final SensorId _sensorId;

  const SensorInfoWidget({super.key, required sensorId}) : _sensorId = sensorId;

  @override
  State<SensorInfoWidget> createState() => _SensorInfoWidgetState();
}

class _SensorInfoWidgetState extends State<SensorInfoWidget> {
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: Future.sync(() async {
          var sensorInfo =
              await SensorManager().getSensorInfo(widget._sensorId);
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
            var sensorConfig =
                SensorManager().getSensorConfig(widget._sensorId)!;
            var sensorInfoUnitText =
                unitToStringRepresentation[sensorInfo.unit];
            var sensorConfigUnitText =
                unitToStringRepresentation[sensorConfig.targetUnit]!;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Unit: $sensorInfoUnitText"),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 22,
                    ),
                    Text(sensorConfigUnitText),
                  ],
                ),
                Text("Accuracy: ${sensorInfo.accuracy.name}"),
                Text("Interval: ${sensorInfo.timeIntervalInMilliseconds} ms"),
                const SizedBox(height: 10),
                MaterialButton(
                  color: Colors.blue,
                  shape: const StadiumBorder(),
                  child: const Text("Update interval"),
                  onPressed: () async {
                    var newDateTime = await updateSensorInterval(
                      context,
                      sensorInfo.timeIntervalInMilliseconds,
                    );

                    if (newDateTime == null) {
                      return;
                    }

                    var result = await SensorManager().changeSensorTimeInterval(
                      id: widget._sensorId,
                      timeIntervalInMilliseconds:
                          newDateTime.millisecondsSinceEpoch,
                    );

                    if (result == SensorTaskResult.success) {
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
}

Future<DateTime?> updateSensorInterval(
  BuildContext context,
  int timeIntervalInMilliseconds,
) async {
  var currentDateTime = DateTime.fromMillisecondsSinceEpoch(
    timeIntervalInMilliseconds,
    isUtc: true,
  );

  var newDateTime = await DatePicker.showPicker(
    context,
    pickerModel: TimeIntervalPicker(
      startTime: currentDateTime,
    ),
  );

  if (newDateTime == null || currentDateTime.isAtSameMomentAs(newDateTime)) {
    return null;
  }

  return newDateTime;
}
