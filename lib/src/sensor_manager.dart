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
  Stream<SensorData>? getSensorStream(SensorId id) => _sensorDataStreams[id];

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Checks if the Sensor is available and returns the SensorID.
  Future<bool> isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  Future<ResultWrapper> changeSensorTimeInterval(
    SensorId id,
    int timeIntervalInMilliseconds,
  ) async =>
      SensorManagerApi()
          .changeSensorTimeInterval(id, timeIntervalInMilliseconds);

  /// Retrieves information about the sensor with the passed [SensorId].
  Future<SensorInfo> getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id);

  /// Starts the tracking of a [SensorId] and returns an matching
  /// [SensorTaskResult].
  Future<SensorTaskResult> startSensorTracking(
    SensorId id,
    int timeIntervalInMilliseconds,
  ) async {
    /// Checks whether the sensor is in use and outputs a corresponding
    /// SensorTaskResult
    if (_usedSensors.contains(id)) {
      return SensorTaskResult.alreadyTrackingSensor;
    }

    if (!await isSensorAvailable(id)) {
      return SensorTaskResult.sensorNotAvailable;
    }

    /// Starts tracking it on the specific platform and returns a
    /// SensorTaskResult
    var startTrack = await SensorManagerApi()
        .startSensorTracking(id, timeIntervalInMilliseconds)
        .then((value) => value.state);

    /// Checks if the expected result from startTrack is a success
    if (startTrack == SensorTaskResult.success) {
      /// Creates an eventChannel to get the sensorData from native Side and
      /// saves it in [_sensorDataStreams]
      var sensorName = id.name;
      var eventChannel = EventChannel('sensors/$sensorName');
      var eventStream = eventChannel
          .receiveBroadcastStream()
          .map((data) => SensorData.decode(data as Object));

      _sensorDataStreams[id] = eventStream;
      _usedSensors.add(id);
    }
    return startTrack;
  }

  /// Stops the tracking from Sensor and returns an bool.
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async {
    /// Checks if the Sensor is being used.
    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }

    /// Stops tracking on the specific platform and returns a
    /// SensorTaskResult
    var stopTrack = await SensorManagerApi()
        .stopSensorTracking(id)
        .then((value) => value.state);

    if (stopTrack == SensorTaskResult.success) {
      _usedSensors.remove(id);
      _sensorDataStreams.remove(id);
    }

    return stopTrack;
  }

  /// These methods below are probably not to be used.

  /// returns all Sensor that are being used.
  List<SensorId> getUsedSensors() => _usedSensors;

  /// checks if the Sensor can be used and returns a List.
  Future<List<SensorId>> getUsableSensors() async {
    var usableSensors = <SensorId>[];
    for (var id in SensorId.values) {
      if (_usedSensors.contains(id) && await isSensorAvailable(id)) {
        usableSensors.add(id);
      }
    }
    return usableSensors;
  }

  /// configure the sensor properties
  bool editSensor() => false;
}
