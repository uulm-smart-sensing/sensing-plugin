import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show SensorManagerApi, SensorData, SensorId, SensorInfo, SensorTaskResult;
import 'preprocessing/preprocessor.dart';
import 'preprocessing/sensor_config.dart';

/// Singleton sensor manager class
class SensorManager {
  /// Stores all Sensors which is being used.
  final List<SensorId> _usedSensors = [];

  /// Stores all received [Stream] with the matching [SensorId] as [SensorData].
  final Map<SensorId, StreamPair<SensorData>> _sensorDataStreams =
      <SensorId, StreamPair<SensorData>>{};

  /// The defined [SensorConfig] for a sensor identified by the [SensorId] used
  /// by the preprocessing.
  final Map<SensorId, SensorConfig> _sensorIdToSensorConfig =
      <SensorId, SensorConfig>{};

  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance.
  factory SensorManager() => _singleton;

  SensorManager._internal();

  /// Process the [SensorData] with a matching [SensorId] from the Native side
  /// and decode it.Furthermore saves every [Stream] with the matching
  /// [SensorId] in [_sensorDataStreams]
  Stream<SensorData>? getSensorStream(SensorId id) =>
      _sensorDataStreams[id]?._streamController.stream;

  /// Checks if the Sensor is currently used and returns an bool.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Checks if the Sensor is available and returns the SensorID.
  Future<bool> isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Changes the interval of the sensor with the passed [id] to
  /// [timeIntervalInMilliseconds] ms.
  ///
  /// The corresponding [SensorConfig] is adjusted accordingly, if the change
  /// was successful.
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

  /// Retrieves information about the sensor with the passed [SensorId].
  Future<SensorInfo> getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id);

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
            (data) => processData(
              sensorData: SensorData.decode(data as Object),
              sensorConfig: config,
            ),
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
  /// If the sensor is not already being tracked
  /// [SensorTaskResult.notTrackingSensor] is returned.
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async {
    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }

    // Stops Flutter specific sensor subscribtion first.
    // Otherwise the speficic platform returns an error.
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
