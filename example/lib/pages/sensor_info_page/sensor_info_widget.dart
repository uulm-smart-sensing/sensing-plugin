import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

import 'time_interval_picker.dart';

class SensorInfoWidget extends StatefulWidget {
  final SensorId _sensorId;

  const SensorInfoWidget({super.key, required sensorId}) : _sensorId = sensorId;

  @override
  State<SensorInfoWidget> createState() => _SensorInfoWidgetState();
}

class _SensorInfoWidgetState extends State<SensorInfoWidget> {
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _getSensorInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "An error occured while loading sensor information",
              style: TextStyle(color: Colors.red),
            );
          }

          if (snapshot.hasData) {
            var sensorInfo = snapshot.data!;
            return Column(
              children: [
                _getSensorInfoColumn(sensorInfo),
                const SizedBox(height: 10),
                _getUpdateIntervalButton(sensorInfo),
              ],
            );
          }

          return const Text(
            "Loading sensor information ...",
            style: TextStyle(color: Colors.grey),
          );
        },
      );

  Future<SensorInfo> _getSensorInfo() =>
      SensorManager().getSensorInfo(widget._sensorId);

  Widget _getSensorInfoColumn(SensorInfo sensorInfo) {
    var sensorConfig = SensorManager().getSensorConfig(widget._sensorId)!;
    var sensorInfoUnitText = sensorInfo.unit.toTextDisplay(isShort: true);
    var sensorConfigUnitText =
        sensorConfig.targetUnit.toTextDisplay(isShort: true);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Unit: $sensorInfoUnitText (source)"),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                ),
                Text("$sensorConfigUnitText (target)"),
              ],
            ),
            Text("Accuracy: ${sensorInfo.accuracy.name}"),
            Text(
              "Interval: ${sensorInfo.timeIntervalInMilliseconds} ms",
            ),
          ],
        ),
      ],
    );
  }

  Widget _getUpdateIntervalButton(SensorInfo sensorInfo) => MaterialButton(
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
            timeIntervalInMilliseconds: newDateTime.millisecondsSinceEpoch,
          );

          if (result == SensorTaskResult.success) {
            setState(() {});
          }
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
