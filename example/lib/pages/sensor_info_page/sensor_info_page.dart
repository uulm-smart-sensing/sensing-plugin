import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sensing_plugin/sensing_plugin.dart';

import 'time_interval_picker.dart';

class SensorInfoPage extends StatefulWidget {
  final SensorId _sensorId;

  const SensorInfoPage({super.key, required SensorId sensorId})
      : _sensorId = sensorId;

  @override
  State<SensorInfoPage> createState() => _SensorInfoPageState();
}

class _SensorInfoPageState extends State<SensorInfoPage> {
  SensorConfig? newSensorConfig;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Sensing Plugin Demo'),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    widget._sensorId.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _getConfigurationSection(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: MaterialButton(
                  color: Colors.blue,
                  shape: const StadiumBorder(),
                  child: const Text(
                    "Apply changes",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  onPressed: () async {
                    if (newSensorConfig == null) {
                      return;
                    }

                    var result = await SensorManager().setSensorConfig(
                      widget._sensorId,
                      newSensorConfig!,
                    );

                    if (result == SensorTaskResult.success) {
                      showSnackBar("Sensor config updated successfully");
                    } else {
                      showSnackBar("Failed to update sensor config");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Future<SensorInfo> _getSensorInfo() =>
      SensorManager().getSensorInfo(widget._sensorId);

  Widget _getConfigurationSection() => FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "An error occurred while loading sensor information",
              style: TextStyle(color: Colors.red),
            );
          }

          if (snapshot.hasData) {
            var sensorInfo = snapshot.data!;
            var sensorInfoUnitText =
                sensorInfo.unit.toTextDisplay(isShort: true);
            newSensorConfig ??=
                SensorManager().getSensorConfig(widget._sensorId);
            return Column(
              children: [
                _getUnitSection(sensorInfoUnitText),
                const SizedBox(height: 8),
                Text("Accuracy: ${sensorInfo.accuracy.name}"),
                const SizedBox(height: 8),
                _getTimeIntervalSection(),
              ],
            );
          }

          return const Text(
            "Loading sensor information ...",
            style: TextStyle(color: Colors.grey),
          );
        },
        future: _getSensorInfo(),
      );

  Widget _getUnitSection(String sensorInfoUnitText) {
    var targetUnit = newSensorConfig!.targetUnit;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Unit: $sensorInfoUnitText (source)"),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 22,
            ),
            Text("${targetUnit.toTextDisplay(isShort: true)} (target)"),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [
                Colors.black,
                Colors.transparent,
                Colors.transparent,
                Colors.black,
              ],
              // 10% black, 80% transparent, 10% black
              stops: [0.0, 0.05, 0.95, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstOut,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _getTargetUnits(targetUnit)
                    .map(
                      (unit) => [
                        _getUnitSelectionButton(unit, targetUnit),
                        const SizedBox(width: 10)
                      ],
                    )
                    .expand((element) => element)
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getUnitSelectionButton(Unit unit, Unit targetUnit) => MaterialButton(
        color: unit == targetUnit ? Colors.blue : Colors.grey,
        shape: const StadiumBorder(),
        child: Text(unit.toTextDisplay(isShort: true)),
        onPressed: () {
          setState(() {
            newSensorConfig = newSensorConfig!.copyWith(targetUnit: unit);
          });
        },
      );

  Widget _getTimeIntervalSection() {
    var timeIntervalInMilliseconds =
        newSensorConfig?.timeInterval.inMilliseconds ?? 10;

    return Column(
      children: [
        Text("Interval: $timeIntervalInMilliseconds ms"),
        _getUpdateIntervalButton(timeIntervalInMilliseconds),
      ],
    );
  }

  Widget _getUpdateIntervalButton(int timeIntervalInMilliseconds) =>
      MaterialButton(
        color: Colors.blue,
        shape: const StadiumBorder(),
        child: const Text("Update interval"),
        onPressed: () async {
          var newDateTime = await updateSensorInterval(
            context,
            timeIntervalInMilliseconds,
          );

          if (newDateTime == null) {
            return;
          }

          setState(() {
            newSensorConfig = newSensorConfig!.copyWith(
              timeInterval:
                  Duration(milliseconds: newDateTime.millisecondsSinceEpoch),
            );
          });
        },
      );

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

  List<Unit> _getTargetUnits(Unit unit) {
    switch (unit.runtimeType) {
      case Acceleration:
        return Acceleration.values;
      case Angle:
        return Angle.values;
      case AngularVelocity:
        return AngularVelocity.values;
      case MagneticFluxDensity:
        return MagneticFluxDensity.values;
      case Pressure:
        return Pressure.values;
      case Temperature:
        return Temperature.values;
    }
    return [];
  }
}
