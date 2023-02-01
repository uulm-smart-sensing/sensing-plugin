import 'package:flutter/material.dart';
import 'dart:collection';
import 'dart:async';

import 'package:sensor_demo/sensor_demo.dart';
import 'package:sensor_demo/sensors.dart';
import 'package:sensor_demo/buffer_manager.dart';
import 'package:sensor_demo/sensor_data.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _accelAvailable = false;
  bool _gyroAvailable = false;
  final HashMap _subscriptions = HashMap<int, StreamSubscription>();

  @override
  void initState() {
    _checkAccelerometerStatus();
    _checkGyroscopeStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptions.forEach((key, value) {
      (value as StreamSubscription).cancel();
    });
  }

  void _checkAccelerometerStatus() async {
    await SensorDemo().isSensorAvailable(Sensors.ACCELEROMETER).then((result) {
      setState(() {
        _accelAvailable = result;
      });
    });
  }

  void _checkGyroscopeStatus() async {
    await SensorDemo().isSensorAvailable(Sensors.GYROSCOPE).then((result) {
      setState(() {
        _gyroAvailable = result;
      });
    });
  }

  Future<void> _startSensor(int senID, List<double> data) async {
    if (!_subscriptions.containsKey(senID)) {
      final stream = await SensorDemo().sensorUpdates(
        sensorId: senID,
      );
      BufferManager().addBuffer(senID);
      var tmpStream = stream.listen((sensorEvent) {
        BufferManager()
            .fillBuffer(senID, SensorData(data[0], data[1], data[2]));
        setState(() {
          data.clear();
          data.addAll(sensorEvent.data);
        });
      });
      _subscriptions[senID] = tmpStream;
    }
  }

  void _stopSensor(int senID) {
    if (_subscriptions.containsKey(senID)) {
      (_subscriptions[senID] as StreamSubscription).cancel();
      _subscriptions.remove(senID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Demo App',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Sensor Demo App'),
          ),
          body: Center(
            child: Column(
              children: [
                SensorInterface(
                    sensorName: "Acc",
                    isSensorAvailable: _accelAvailable,
                    subFunction: _startSensor,
                    id: Sensors.ACCELEROMETER,
                    deSubFunction: _stopSensor),
                SensorInterface(
                    sensorName: "Gyro",
                    isSensorAvailable: _gyroAvailable,
                    subFunction: _startSensor,
                    id: Sensors.GYROSCOPE,
                    deSubFunction: _stopSensor),
                MaterialButton(
                  onPressed: () async {
                    if (BufferManager().isDatabaseReady()) {
                      var records = await BufferManager().readFromDatabase();
                      for (var record in records) {
                        print(record.toString());
                      }
                    }
                  },
                  color: Colors.blue,
                  child: const Text("DataBase Entrys"),
                )
              ],
            ),
          )),
    );
  }
}

class ValueBar extends StatefulWidget {
  final List<double> data;

  const ValueBar({super.key, required this.data});
  @override
  State<StatefulWidget> createState() => _ValueBarState();
}

class _ValueBarState extends State<ValueBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("[0](X) = ${widget.data[0].toStringAsFixed(2)}",
            textAlign: TextAlign.center),
        Text("[1](Y) = ${widget.data[1].toStringAsFixed(2)}",
            textAlign: TextAlign.center),
        Text("[2](Z) = ${widget.data[2].toStringAsFixed(2)}",
            textAlign: TextAlign.center),
      ],
    );
  }
}

class SensorInterface extends StatefulWidget {
  final String sensorName;
  final bool isSensorAvailable;
  final int id;
  final Function(int, List<double>) subFunction;
  final Function(int) deSubFunction;
  const SensorInterface(
      {super.key,
      required this.sensorName,
      required this.isSensorAvailable,
      required this.subFunction,
      required this.id,
      required this.deSubFunction});

  @override
  State<SensorInterface> createState() => _SensorInterfaceState();
}

class _SensorInterfaceState extends State<SensorInterface> {
  List<double> data = <double>[0, 0, 0];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.sensorName,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        ValueBar(data: data),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        StartButton(
            data: data,
            subFunction: widget.subFunction,
            deSubFunction: widget.deSubFunction,
            isSensorAvailable: widget.isSensorAvailable,
            id: widget.id),
        MedianButton(sensorDataMedian: SensorData(0, 0, 0), id: widget.id)
      ],
    );
  }
}

class StartButton extends StatefulWidget {
  final bool isSensorAvailable;
  final Function(int, List<double>) subFunction;
  final Function(int) deSubFunction;
  final int id;
  final List<double> data;
  const StartButton({
    super.key,
    required this.subFunction,
    required this.deSubFunction,
    required this.id,
    required this.data,
    required this.isSensorAvailable,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool recording = false;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: recording
          ? () {
              widget.deSubFunction(widget.id);
              setState(() {
                recording = false;
              });
            }
          : () {
              widget.subFunction(widget.id, widget.data);
              setState(() {
                recording = true;
              });
            },
      color: widget.isSensorAvailable && !recording ? Colors.green : Colors.red,
      child: !recording ? const Text("Start") : const Text("Stop"),
    );
  }
}

class MedianButton extends StatefulWidget {
  final SensorData sensorDataMedian;
  final int id;
  const MedianButton(
      {super.key, required this.sensorDataMedian, required this.id});

  @override
  State<MedianButton> createState() => _MedianButtonState();
}

class _MedianButtonState extends State<MedianButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        print(BufferManager().medianAllData(widget.id).toString());
      },
      color: Colors.blue,
      child: const Text("Median"),
    );
  }
}
