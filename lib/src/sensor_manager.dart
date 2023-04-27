import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show SensorManagerApi, InternalSensorData, SensorId, SensorTaskResult;
import 'preprocessing/preprocessor.dart';
import 'preprocessing/sensor_data.dart';
import 'sensor_config.dart';
import 'sensor_info.dart';

/// Singleton sensor manager class
class SensorManager {
  /// List of all sensors in use.
  final _usedSensors = <SensorId>[];

  /// The [StreamPair] of a sensor with the corresponding [SensorId].
  final _sensorDataStreams = <SensorId, StreamPair>{};

  /// The defined [SensorConfig] for a sensor identified by the [SensorId] used
  /// by the preprocessing.
  final _sensorIdToSensorConfig = <SensorId, SensorConfig>{};

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Returns the [Stream] of the sensor with the passed [id].
  ///
  /// If the sensor is not being tracked, i.e. no stream is available, null is
  /// returned.
  Stream<SensorData>? getSensorStream(SensorId id) =>
      _sensorDataStreams[id]?._streamController.stream;

  /// Checks whether the sensor with the passed [id] is currently used.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Checks whether the sensor with the passed [id] is available.
  Future<bool> isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Changes the time interval of the sensor with the passed [id] to
  /// [timeIntervalInMilliseconds] ms.
  ///
  /// The corresponding [SensorConfig] is adjusted accordingly,
  /// if the change was successful.
  ///
  /// If the sensor is not already being tracked
  /// [SensorTaskResult.notTrackingSensor] is returned.
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) async {
    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }

    var result = await SensorManagerApi()
        .changeSensorTimeInterval(id, timeIntervalInMilliseconds)
        .then((value) => value.state);

    if (result == SensorTaskResult.success) {
      var oldConfig = _sensorIdToSensorConfig[id]!;
      var newConfig = oldConfig.copyWith(
        timeInterval: Duration(
          milliseconds: timeIntervalInMilliseconds,
        ),
      );
      _sensorIdToSensorConfig[id] = newConfig;
    }

    return result;
  }

  /// Retrieves information about the sensor with the passed [id].
  Future<SensorInfo> getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id).then(sensorInfoFromInternal);

  /// Returns the stored [SensorConfig] for the sensor with the passed [id].
  ///
  /// If there's no [SensorConfig] associated with the passed [id], null is
  /// returned.
  SensorConfig? getSensorConfig(SensorId id) => _sensorIdToSensorConfig[id];

  /// Starts the tracking of a sensor with the passed [id].
  ///
  /// If the tracking is started successfully, the passed [config] is stored and
  /// used to configure the time interval and how the sensor data is
  /// preprocessed.
  ///
  /// If the sensor is already being tracked
  /// [SensorTaskResult.alreadyTrackingSensor] is returned.
  /// If the sensor is not available (according to [isSensorAvailable])
  /// [SensorTaskResult.sensorNotAvailable] is returned.
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) async {
    if (_usedSensors.contains(id)) {
      return SensorTaskResult.alreadyTrackingSensor;
    }

    if (!await isSensorAvailable(id)) {
      return SensorTaskResult.sensorNotAvailable;
    }

    var result = await SensorManagerApi()
        .startSensorTracking(id, config.timeInterval.inMilliseconds)
        .then((value) => value.state);

    if (result == SensorTaskResult.success) {
      // Creates an eventChannel to get the sensorData from native side and
      // saves it in _sensorDataStreams
      var sensorName = id.name;
      var eventChannel = EventChannel('sensors/$sensorName');
      var eventStream = eventChannel.receiveBroadcastStream().map(
            (data) =>
                processData(InternalSensorData.decode(data as Object), config),
          );
      _sensorDataStreams[id] = StreamPair(eventStream);
      _usedSensors.add(id);
      _sensorIdToSensorConfig[id] = config;
    }

    return result;
  }

  /// Stops the tracking of a sensor with the passed [id].
  ///
  /// If the tracking is stopped successfully the stored [SensorConfig] is
  /// removed.
  ///
  /// Returns:
  /// * [SensorTaskResult.notTrackingSensor] if the sensor is not being tracked.
  /// * [SensorTaskResult.failure] if the tracking could not be stopped.
  /// * [SensorTaskResult.success] if the tracking was stopped successfully.
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async {
    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }

    // Stops Flutter specific sensor subscription first.
    // Otherwise the specific platform returns an error.
    try {
      await _sensorDataStreams[id]?._streamSubscription.cancel();
      await _sensorDataStreams[id]?._streamController.close();
    } on Exception catch (e) {
      log(e.toString());
      return SensorTaskResult.failure;
    }

    var result = await SensorManagerApi()
        .stopSensorTracking(id)
        .then((value) => value.state);

    if (result == SensorTaskResult.success) {
      _usedSensors.remove(id);
      _sensorDataStreams.remove(id);
      _sensorIdToSensorConfig.remove(id);
    }

    return result;
  }

  /// Returns all sensors in use.
  List<SensorId> getUsedSensors() => _usedSensors;

  /// Returns all sensors that are available and not in use.
  Future<List<SensorId>> getUsableSensors() async {
    var usableSensors = <SensorId>[];
    for (var id in SensorId.values) {
      if (!_usedSensors.contains(id) && await isSensorAvailable(id)) {
        usableSensors.add(id);
      }
    }
    return usableSensors;
  }

  /// configure the sensor properties
  bool editSensor() => false;
}

///Class to convert a stream to a stream controller.
///Contains both the controller and
///the base subscription to the initial stream.
class StreamPair<T> {
  final StreamController<T> _streamController = StreamController<T>.broadcast();
  late final StreamSubscription<T> _streamSubscription;

  ///Constructor to convert a regular stream to a stream controller.
  StreamPair(Stream<T> baseStream) {
    _streamSubscription = baseStream.listen((event) {
      if (!_streamController.isClosed || !_streamController.isPaused) {
        _streamController.add(event);
      }
    });
  }
}
