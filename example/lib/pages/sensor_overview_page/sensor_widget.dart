import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import '../sensor_info_page/sensor_info_page.dart';
import 'sensor_data_container.dart';

/// Example target [Unit]s for each [SensorId] using by this demo app.
const sensorIdToTargetUnit = {
  SensorId.accelerometer: Unit.metersPerSecondSquared,
  SensorId.gyroscope: Unit.degreesPerSecond,
  SensorId.magnetometer: Unit.microTeslas,
  SensorId.orientation: Unit.degrees,
  SensorId.linearAcceleration: Unit.metersPerSecondSquared,
  SensorId.barometer: Unit.hectoPascal,
  SensorId.thermometer: Unit.celsius,
};

class SensorWidget extends StatefulWidget {
  final SensorId _sensorId;
  final bool _showWhenUnavailable;

  const SensorWidget({
    super.key,
    required SensorId sensorId,
    required bool showWhenUnavailable,
  })  : _sensorId = sensorId,
        _showWhenUnavailable = showWhenUnavailable;

  @override
  State<SensorWidget> createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  var _isAvailable = false;
  var _isRunning = false;
  final _targetPrecision = 2;

  SensorDataContainer? dataContainer;

  @override
  void initState() {
    SensorManager().isSensorAvailable(widget._sensorId).then(
          (value) => setState(
            () => _isAvailable = value,
          ),
        );
    super.initState();
  }

  @override
  void dispose() {
    _stopSensor();
    super.dispose();
  }

  Future<SensorTaskResult> _startSensor() async {
    var result = await SensorManager().startSensorTracking(
      id: widget._sensorId,
      config: SensorConfig(
        targetUnit: sensorIdToTargetUnit[widget._sensorId]!,
        targetPrecision: _targetPrecision,
        timeInterval: const Duration(milliseconds: 100),
      ),
    );
    if (result == SensorTaskResult.success) {
      setState(() {
        dataContainer = SensorDataContainer(
          stream: SensorManager().getSensorStream(widget._sensorId)!,
          displayedDecimalPlaces: _targetPrecision,
        );
      });
    }
    if (kDebugMode) {
      log("Started sensor ${widget._sensorId.name} with result ${result.name}");
    }
    return result;
  }

  Future<SensorTaskResult> _stopSensor() async {
    var result = await SensorManager().stopSensorTracking(widget._sensorId);
    setState(() {
      dataContainer = null;
    });
    if (kDebugMode) {
      log("Stopped sensor ${widget._sensorId.name} with result ${result.name}");
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable && !widget._showWhenUnavailable) {
      return const SizedBox.shrink();
    }

    var infoButton = IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensorInfoPage(
              sensorId: widget._sensorId,
            ),
          ),
        );
      },
      icon: const Icon(Icons.info_outline),
    );

    var titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget._sensorId.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );

    if (_isRunning) {
      titleRow.children.add(infoButton);
    }

    return Column(
      children: [
        titleRow,
        const SizedBox(height: 2),
        dataContainer ?? const SizedBox.shrink(),
        const SizedBox(height: 4),
        MaterialButton(
          color: _isAvailable
              ? (_isRunning ? Colors.red : Colors.green)
              : Colors.grey,
          onPressed: () {
            if (!_isAvailable) {
              return;
            }

            if (_isRunning) {
              _stopSensor();
            } else {
              _startSensor();
            }
            setState(() {
              _isRunning = !_isRunning;
            });
          },
          child: _isAvailable
              ? (_isRunning ? const Text("Stop") : const Text("Start"))
              : const Text("Not available"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

Widget getSensorButton({
  required bool isAvailable,
  required bool isRunning,
  required Function onPressedFunction,
}) =>
    MaterialButton(
      color:
          isAvailable ? (isRunning ? Colors.red : Colors.green) : Colors.grey,
      onPressed: () {
        if (isAvailable) {
          onPressedFunction.call();
        }
      },
      child: isAvailable
          ? (isRunning ? const Text("Stop") : const Text("Start"))
          : const Text("Not available"),
    );
