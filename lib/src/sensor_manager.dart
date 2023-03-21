// ignore_for_file: unused_element, prefer_final_fields, unused_field

import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show
        SensorManagerApi,
        SensorData,
        Unit,
        SensorId,
        SensorInfo,
        ResultWrapper;
import 'preprocessing/preprocessor.dart';
import 'sensor.dart';

/// Singleton sensor manager class

class SensorManager {
  // Stores all Sensors which is being used.
  List<Sensor> _usedSenors = [];

  // Stores all Sensors.
  List<Sensor> _allSensors = [];

  // Stores all received [Stream].
  List<Stream> _sensorStreams = [];

  // Map Object with a SensorId and a Preprocessor
  Map<SensorId, Preprocessor> _preprocessor = <SensorId, Preprocessor>{};

  // The EventChannel name used to get the data from the native site.
  final EventChannel _eventStream = const EventChannel('sensors/%id');

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Process the [SensorData] which i get from the Native side and decode it.
  Stream<SensorData> getSensorStream() => _eventStream
      .receiveBroadcastStream()
      .map((data) => SensorData.decode(data as Object));

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  // Checks if the Sensor is available and returns the SensorID.
  Future<bool> _isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  // Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  Future<ResultWrapper> _changeSensorTimeInterval(
    SensorId id,
    int timeIntervalInMilliseconds,
  ) async =>
      SensorManagerApi()
          .changeSensorTimeInterval(id, timeIntervalInMilliseconds);

  /// Retrieves information about the sensor with the passed [SensorId]git .
  Future<SensorInfo> _getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id);

  /// Tracks if a Sensor is being used and returns an bool.
  Future<bool> startSensorTracking(
    SensorId id,
    Unit units,
    int precision,
    Duration timeInterval,
  ) async {
    // Checks first if the sensor we want to track is available at all.
    if (await _isSensorAvailable(id)) {
      return true;
    } else {
      // Sets the help variable false and returns it.
      return false;
    }
  }

  /// Stops the tracking from Sensor and returns an bool.
  Future<bool> stopSensorTracking(Sensor sensor) async {
    // Checks if the Sensor is being tracked.
    if (await startSensorTracking(
        sensor.id, sensor.unit, sensor.accuracy, sensor.timeInterval)) {
      //Removes the Sensor from _usedSensors
      //because the Sensor is not being used anymore.
      _usedSenors.remove(sensor);
      // Sets the help variable on false.
      return true;
    }
    return false;
  }

  /// Gets the List from all Sensor which currently being used and returns it.
  List<Sensor> getUsedSensors() => _usedSenors;

  /// Gets the list of all currently available sensors and returns the
  /// difference between _allSensors and _usedSensors
  ///
  /// Example usage:
  /// ``` dart
  /// _allSensor =[accelerometer,gyroscope,magnetometer,heading];
  /// _usedSensors = [accelerometer,heading];
  /// var notBeingUsed = getUsableSensors();
  ///
  ///print (notBeingUsed)  // [magnetometer,gyroscope]
  ///```
  List<Sensor> getUsableSensors() =>
      _allSensors.toSet().difference(_usedSenors.toSet()).toList();

  /// Search a Sensor and returns the List
  List<Sensor> getSensor(String name) {
    // The list of found Sensors
    var foundSensors = <Sensor>[];
    // iterates through _usedSensors
    for (var sensor in _usedSenors) {
      // Checks if the name is identical with the searched name
      if (sensor.name == name) {
        // Adds it to the list of found Sensors
        foundSensors.add(sensor);
      }
    }
    // Returns all found Sensors
    return foundSensors;
  }

  // ignore: todo
  /// TODO: implement and document this method
  bool editSensor() => false;

  // ignore: todo
  /// TODO: implement and document this method
  void _initializeAllSensors() {}

  // ignore: todo
  /// TODO: implement and document this method
  void _makeAvailableSensorsUsable() {}
}
