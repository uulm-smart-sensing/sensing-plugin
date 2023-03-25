import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show
        SensorManagerApi,
        SensorData,
        SensorId,
        SensorInfo,
        ResultWrapper,
        SensorTaskResult;
import 'preprocessing/preprocessor.dart';

/// Singleton sensor manager class
class SensorManager {
  /// Stores all Sensors which is being used.
  final List<SensorId> usedSenors = [];

  /// Stores all Sensors which are available.
  final List<SensorId> availableSensors = [];

  /// Stores all received [Stream].
  final List<Stream> sensorStreams = [];

  /// Map Object with a SensorId and a Preprocessor
  Map<SensorId, Preprocessor> sensorIdToPreprocessor = <SensorId, Preprocessor>{};

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Process the [SensorData] with a matching [SensorId] from the Native side
  /// and decode it.
  Stream<SensorData> getSensorStream(SensorId id) {
    var eventStream = EventChannel('sensors/$id');
    return eventStream
        .receiveBroadcastStream()
        .map((data) => SensorData.decode(data as Object));
  }

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  // Checks if the Sensor is available and returns the SensorID.
  Future<bool> _isSensorAvailable(SensorId id) async => SensorManagerApi().isSensorAvailable(id);

  // Changes the interval of the sensor event channel with the passed
  // [SensorId] to [timeIntervalInMilliseconds] ms.
  Future<ResultWrapper> _changeSensorTimeInterval(
    SensorId id,
    int timeIntervalInMilliseconds,
  ) async =>
      SensorManagerApi()
          .changeSensorTimeInterval(id, timeIntervalInMilliseconds);

  /// Retrieves information about the sensor with the passed [SensorId].
  Future<SensorInfo> _getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id);

  /// Tracks if a Sensor is being used and returns an bool.
  Future<SensorTaskResult> startSensorTracking(SensorId id) {
    var sensorStream = EventChannel('sensors/$id');
    // Checks if Sensor is available
    if (_availableSensors.contains(id)) {
      // Checks if Sensor is in use
      if (_usedSenors.contains(id)) {
        return Future.value(SensorTaskResult.alreadyTrackingSensor);
      } else {
        // Converts stream into a Stream<ResultWrapper> and then applies the
        // decode() method to each element to convert it into a ResultWrapper
        // object. The last function returns the last element of the stream and
        // then function handle the object and output the state value as an
        // SensorTaskResult
        var stream = sensorStream
            .receiveBroadcastStream()
            .map((data) => ResultWrapper.decode(data as ResultWrapper))
            .last
            .then((value) => value.state);
        // Adds the Sensor to the list
        _usedSenors.add(id);
        return stream;
      }
    }
    // Returns an error if the condition is not met
    return Future.value(SensorTaskResult.failure);
  }

  /// Stops the tracking from Sensor and returns an bool.
  SensorTaskResult stopSensorTracking(SensorId id) {
    // Checks if the Sensor is being tracked.
    if (_usedSenors.contains(id)) {
      // Cancel the EventChannel
      MethodChannel('sensors/$id').setMethodCallHandler(null);
      return SensorTaskResult.success;
    } else {
      return SensorTaskResult.notTrackingSensor;
    }
  }

  /// Gets the List from all Sensor which currently being used and returns it.
  List<SensorId> getUsedSensors() => _usedSenors;

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
  List<SensorId> getUsableSensors() =>
      _availableSensors.toSet().difference(_usedSenors.toSet()).toList();

  /// Search a Sensor and returns the List
  List<SensorId> getSensor(String name) {
    // The list of found Sensors
    var foundSensors = <SensorId>[];
    // iterates through _usedSensors
    for (var sensor in _usedSenors) {
      // Checks if the name is identical with the searched name
      if (sensor.name.toLowerCase().startsWith(name.toLowerCase())) {
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
