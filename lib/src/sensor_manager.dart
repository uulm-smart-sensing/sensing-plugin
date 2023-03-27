// ignore_for_file: unused_element, unused_field

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
  final List<SensorId> _usedSensors = [];

  /// Stores all received [Stream] with the matching [SensorId] as [SensorData].
  final Map<SensorId, Stream<SensorData>> _sensorDataStreams =
      <SensorId, Stream<SensorData>>{};

  /// Map Object with a SensorId and a Preprocessor
  final Map<SensorId, Preprocessor> _sensorIdToPreprocessor =
      <SensorId, Preprocessor>{};

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Process the [SensorData] with a matching [SensorId] from the Native side
  /// and decode it.Furthermore saves every [Stream] with the matching
  /// [SensorId] in [_sensorDataStreams]
  Stream<SensorData> getSensorStream(SensorId id) {
    var sensorName = id.name;
    var eventChannel = EventChannel('sensors/$sensorName');
    var eventStream = eventChannel
        .receiveBroadcastStream()
        .map((data) => SensorData.decode(data as Object));
    _sensorDataStreams[id] = eventStream;
    return eventStream;
  }

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Checks if the Sensor is available and returns the SensorID.
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

  /// Starts the tracking of a [SensorId] and returns an matching
  /// [SensorTaskResult].
  Future<SensorTaskResult> startSensorTracking(
    SensorId id,
    int timeIntervalInMilliseconds,
  ) async {
    var sensorTaskName = id.name;
    var taskChannel = EventChannel('sensors/$sensorTaskName');
    var trackStream = taskChannel;

    /// Checks whether the sensor is in use and outputs a corresponding
    /// SensorTaskResult
    if (_usedSensors.contains(id)) {
      return Future.value(SensorTaskResult.alreadyTrackingSensor);
    }

    /// Checks whether the Sensor is not available
    if (!await _isSensorAvailable(id)) {
      return Future.value(SensorTaskResult.sensorNotAvailable);
    }

    /// Starts tracking it on the specific platform and returns a
    /// SensorTaskResult
    var startTrack = await SensorManagerApi()
        .startSensorTracking(id, timeIntervalInMilliseconds)
        .then((value) => value.state);

    /// checks if the expected result from startTrack is a success
    if (startTrack == SensorTaskResult.success) {
      /// Converts stream into a Stream<ResultWrapper> and then applies the
      /// decode() method to each element to convert it into a ResultWrapper
      /// object. The last function returns the last element of the stream and
      /// then function handle the object and output the state value as an
      /// SensorTaskResult
      var stream = trackStream
          .receiveBroadcastStream()
          .map((data) => ResultWrapper.decode(data as ResultWrapper))
          .last
          .then((value) => value.state);

      /// Adds the Sensor to the list
      _usedSensors.add(id);
      return stream;
    }
    return Future.value(startTrack);
  }

  /// Stops the tracking from Sensor and returns an bool.
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async {
    /// Checks if the Sensor is being used.
    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }
    var stopTrack = SensorManagerApi()
        .stopSensorTracking(id)
        .then((value) => value.state);

    /// Checks if the Result is not successful
    if(stopTrack != Future.value(SensorTaskResult.failure)){
        return SensorTaskResult.failure;
    }

    /// Removes the Sensor from usedSensors.
    _usedSensors.remove(id);

    /// Removes the Sensor from sensorStreams.
    _sensorDataStreams.remove(id);

    /// Stops the tracking on the specific platform and returns a
    /// SensorTaskResult
    return stopTrack;
  }

  /// These methods below are probably not to be used.

  /// returns all Sensor that are being used.
  List<SensorId> getUsedSensors() => _usedSensors;

  /// checks if the Sensor can be used and returns a List.
  Future<List<SensorId>> getUsableSensors() async {
    var usableSensors = <SensorId>[];
    for (var id in SensorId.values) {
      if (_usedSensors.contains(id) && await _isSensorAvailable(id)) {
        usableSensors.add(id);
      }
    }
    return usableSensors;
  }

  /// configure the sensor properties
  bool editSensor() => false;
}
