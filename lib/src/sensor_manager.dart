// ignore_for_file: unused_element

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
  final List<SensorId> usedSensors = [];

  /// Stores all received [Stream].
  Map<SensorId ,Stream> sensorStreams = <SensorId,Stream>{};

  /// Map Object with a SensorId and a Preprocessor
  Map<SensorId, Preprocessor> sensorIdToPreprocessor =
      <SensorId, Preprocessor>{};

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Process the [SensorData] with a matching [SensorId] from the Native side
  /// and decode it.
  Stream<SensorData> getSensorStream(SensorId id) {
    var sensorName = id.name;
    var eventChannel = EventChannel('sensors/$sensorName');
    var eventStream = eventChannel
        .receiveBroadcastStream()
        .map((data) => SensorData.decode(data as Object));
    sensorStreams[id] =eventStream;
        return eventStream;
  }

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  // Checks if the Sensor is available and returns the SensorID.
  Future<bool> _isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
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
  Future<SensorTaskResult> startSensorTracking(
      SensorId id, int timeIntervalInMilliseconds,) async {
    var trackStream = sensorStreams[id] ;
    if (!usedSensors.contains(id)) {
      return Future.value(SensorTaskResult.alreadyTrackingSensor);
    }
    /// Checks if Sensor is available
    if (!await _isSensorAvailable(id)) {
      return Future.value(SensorTaskResult.sensorNotAvailable);
    }
    
    var startTrack = await SensorManagerApi()
        .startSensorTracking(id, timeIntervalInMilliseconds)
        .then((value) => value.state);

    /// Checks if Sensor is in use
    if (startTrack == SensorTaskResult.success) {
      /// Converts stream into a Stream<ResultWrapper> and then applies the
      /// decode() method to each element to convert it into a ResultWrapper
      /// object. The last function returns the last element of the stream and
      /// then function handle the object and output the state value as an
      /// SensorTaskResult
      var stream = trackStream!
          .map((data) => ResultWrapper.decode(data as ResultWrapper))
          .last
          .then((value) => value.state);

      /// Adds the Sensor to the list
      usedSensors.add(id);
      return stream;
    }
    return Future.value(startTrack);

  }

  /// Stops the tracking from Sensor and returns an bool.
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async {
    /// Checks if the Sensor is being tracked.
    if (usedSensors.contains(id)) {
      usedSensors.remove(id);
      return SensorManagerApi()
          .stopSensorTracking(id)
          .then((value) => value.state);
    } else {
      return SensorTaskResult.notTrackingSensor;
    }
  }

  /// Gets the List from all Sensor which currently being used and returns it.
  List<SensorId> getUsedSensors() => usedSensors;

  /// Gets the list of all currently available sensors and returns the
  /// difference between _isSensorAvailable and _usedSensors
  ///
  /// Example usage:
  /// ``` dart
  /// _allSensor =[accelerometer,gyroscope,magnetometer,heading];
  /// _usedSensors = [accelerometer,heading];
  /// var notBeingUsed = getUsableSensors();
  ///
  ///print (notBeingUsed)  // [magnetometer,gyroscope]
  ///```
  Future<List<SensorId>> getUsableSensors() async {
    var usableSensors = <SensorId>[];
    for (var id in SensorId.values) {
      if (usedSensors.contains(id) && await _isSensorAvailable(id)) {
        usableSensors.add(id);
      }
    }
    return usableSensors;
  }

  /// ignore: todo
  /// TODO: implement and document this method
  bool editSensor() => false;
}
