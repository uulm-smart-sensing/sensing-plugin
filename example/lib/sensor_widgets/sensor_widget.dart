import 'package:flutter/material.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin_example/pages/sensor_info_page.dart';
import 'package:sensing_plugin_example/sensor_widgets/sensor_data_container.dart';

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

  SensorDataContainer? dataContainer;

  @override
  void initState() {
    // TODO: check for availability
    super.initState();
  }

  @override
  void dispose() {
    _stopSensor();
    super.dispose();
  }

  Future<SensorTaskResult> _startSensor() async {
    // TODO: start sensor and set dataContainer
    return Future.value(SensorTaskResult.success);
  }

  Future<SensorTaskResult> _stopSensor() async {
    // TODO: stop sensor
    dataContainer = null;
    return Future.value(SensorTaskResult.success);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable && !widget._showWhenUnavailable) {
      return const SizedBox.shrink();
    }

    print("Build SensorWidget");

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget._sensorId.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SensorInfoPage(sensorId: widget._sensorId);
                }));
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 8.0)),
        dataContainer ?? const SizedBox.shrink(),
        const Padding(padding: EdgeInsets.only(top: 4.0)),
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
        const Padding(padding: EdgeInsets.only(top: 10.0)),
      ],
    );
  }
}

Widget getSensorButton({
  required bool isAvailable,
  required bool isRunning,
  required Function onPressedFunction,
}) {
  return MaterialButton(
    color: isAvailable ? (isRunning ? Colors.red : Colors.green) : Colors.grey,
    onPressed: () {
      if (isAvailable) {
        onPressedFunction.call();
      }
    },
    child: isAvailable
        ? (isRunning ? const Text("Stop") : const Text("Start"))
        : const Text("Not available"),
  );
}
