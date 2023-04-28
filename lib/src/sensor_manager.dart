import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show SensorManagerApi, InternalSensorData, SensorId, SensorTaskResult;
import 'preprocessing/preprocessor.dart';
import 'preprocessing/sensor_data.dart';
import 'sensor_config.dart';
import 'sensor_config_validator.dart';
import 'sensor_info.dart';
import 'units/unit.dart';

/// Singleton sensor manager class
class SensorManager {
  /// List of all sensors in use.
  final _usedSensors = <SensorId>[];

  /// The [_StreamPair] of a sensor with the corresponding [SensorId].
  final _sensorDataStreams = <SensorId, _StreamPair>{};

  /// The defined [SensorConfig] wrapped in a [SensorConfigWrapper] for a
  /// sensor identified by the [SensorId] used by the preprocessing.
  final _sensorIdToSensorConfig = <SensorId, SensorConfigWrapper>{};

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
  /// Returns:
  /// * [SensorTaskResult.invalidTimeInterval] if the time interval is invalid
  /// (according to [validateInterval]).
  /// * [SensorTaskResult.notTrackingSensor] if the sensor is not being tracked.
  /// * [SensorTaskResult.success] if the time interval was changed
  /// successfully.
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) async {
    if (!validateInterval(timeIntervalInMilliseconds)) {
      return SensorTaskResult.invalidTimeInterval;
    }

    if (!_usedSensors.contains(id)) {
      return SensorTaskResult.notTrackingSensor;
    }

    var result = await SensorManagerApi()
        .changeSensorTimeInterval(id, timeIntervalInMilliseconds)
        .then((value) => value.state);

    if (result == SensorTaskResult.success) {
      var oldConfig = _sensorIdToSensorConfig[id]!.sensorConfig;
      var newConfig = oldConfig.copyWith(
        timeInterval: Duration(
          milliseconds: timeIntervalInMilliseconds,
        ),
      );
      _sensorIdToSensorConfig[id] = SensorConfigWrapper(newConfig);
    }

    return result;
  }

  /// Retrieves information (collected in a [SensorInfo] object) about the
  /// sensor with the passed [id].
  Future<SensorInfo> getSensorInfo(SensorId id) async =>
      SensorManagerApi().getSensorInfo(id).then(sensorInfoFromInternal);

  /// Returns the stored [SensorConfig] for the sensor with the passed [id].
  ///
  /// If there's no [SensorConfig] associated with the passed [id], null is
  /// returned.
  SensorConfig? getSensorConfig(SensorId id) =>
      _sensorIdToSensorConfig[id]?.sensorConfig;

  /// Starts the tracking of a sensor with the passed [id].
  ///
  /// If the tracking is started successfully, the passed [config] is stored and
  /// used to configure the time interval and how the sensor data is
  /// preprocessed.
  ///
  /// Returns:
  /// * [SensorTaskResult.alreadyTrackingSensor] if the sensor is already being
  /// tracked.
  /// * [SensorTaskResult.sensorNotAvailable] if the sensor is not available
  /// (according to [isSensorAvailable]).
  /// * The corresponding [SensorTaskResult] if the [config] is invalid
  /// (according to [validateSensorConfig]).
  /// * [SensorTaskResult.success] if the tracking was started successfully.
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) async {
    var configValidationResult = validateSensorConfig(id, config);
    if (configValidationResult != SensorTaskResult.success) {
      return configValidationResult;
    }

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
      var configWrapper = SensorConfigWrapper(config);
      // Creates an eventChannel to get the sensorData from native side and
      // saves it in _sensorDataStreams
      var sensorName = id.name;
      var eventChannel = EventChannel('sensors/$sensorName');
      var eventStream = eventChannel.receiveBroadcastStream().map(
            (data) => processData(
              InternalSensorData.decode(data as Object),
              configWrapper,
            ),
          );
      _sensorDataStreams[id] = _StreamPair(eventStream);
      _usedSensors.add(id);
      _sensorIdToSensorConfig[id] = configWrapper;
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

  /// Checks whether the passed [config] is valid for the passed [sensorId].
  ///
  /// Returns:
  /// * [SensorTaskResult.success] if the [config] is valid.
  /// * [SensorTaskResult.invalidTimeInterval] if the
  /// [SensorConfig.timeInterval] is invalid.
  /// * [SensorTaskResult.invalidPrecision] if the
  /// [SensorConfig.targetPrecision] is invalid.
  /// * [SensorTaskResult.invalidUnit] if the [SensorConfig.targetUnit] is
  /// invalid.
  ///
  /// Same as using [validateInterval], [validatePrecision] and
  /// [validateUnit].
  SensorTaskResult validateSensorConfig(
    SensorId sensorId,
    SensorConfig config,
  ) {
    if (!validateInterval(config.timeInterval.inMilliseconds)) {
      return SensorTaskResult.invalidTimeInterval;
    }

    if (!validatePrecision(config.targetPrecision)) {
      return SensorTaskResult.invalidPrecision;
    }

    if (!validateUnit(unit: config.targetUnit, sensorId: sensorId)) {
      return SensorTaskResult.invalidUnit;
    }

    return SensorTaskResult.success;
  }

  /// Edits the [SensorConfig] of a sensor with the passed [sensorId].
  ///
  /// Returns:
  /// * [SensorTaskResult.notTrackingSensor] if the sensor is not being tracked.
  /// * The corresponding [SensorTaskResult] if the [SensorConfig] is invalid
  /// (according to [validateSensorConfig]).
  /// * [SensorTaskResult.success] if the [SensorConfig] was edited
  /// successfully.
  ///
  /// Example:
  /// ```dart
  /// // Changes the time interval of the accelerometer to 1 second.
  /// SensorManager().editSensorConfig(
  ///   SensorId.accelerometer,
  ///   timeInterval: Duration(seconds: 1),
  /// );
  ///
  /// // Changes the precision of the accelerometer to 2.
  /// SensorManager().editSensorConfig(
  ///   SensorId.accelerometer,
  ///   targetPrecision: 2,
  /// );
  ///
  /// // Changes the unit of the accelerometer to m/s^2.
  /// SensorManager().editSensorConfig(
  ///   SensorId.accelerometer,
  ///   targetUnit: Unit.metersPerSecondSquared,
  /// );
  /// ```
  Future<SensorTaskResult> editSensorConfig(
    SensorId sensorId, {
    Unit? targetUnit,
    int? targetPrecision,
    Duration? timeInterval,
  }) async {
    if (!_sensorIdToSensorConfig.containsKey(sensorId)) {
      return SensorTaskResult.notTrackingSensor;
    }

    var sensorConfigWrapper = _sensorIdToSensorConfig[sensorId]!;
    var sensorConfig = sensorConfigWrapper.sensorConfig;
    var newSensorConfig = sensorConfig.copyWith(
      targetUnit: targetUnit,
      targetPrecision: targetPrecision,
      timeInterval: timeInterval,
    );

    var configValidationResult = validateSensorConfig(
      sensorId,
      newSensorConfig,
    );
    if (configValidationResult != SensorTaskResult.success) {
      return configValidationResult;
    }

    var sensorTaskResult = SensorTaskResult.success;
    // If the time interval is changed, the sensor tracking has to be restarted.
    if (sensorConfig.timeInterval != newSensorConfig.timeInterval) {
      sensorTaskResult = await changeSensorTimeInterval(
        id: sensorId,
        timeIntervalInMilliseconds: newSensorConfig.timeInterval.inMilliseconds,
      );
    }

    if (sensorTaskResult != SensorTaskResult.success) {
      return sensorTaskResult;
    }

    sensorConfigWrapper.sensorConfig = newSensorConfig;
    return SensorTaskResult.success;
  }

  /// Sets the [SensorConfig] of a sensor with the passed [sensorId].
  ///
  /// Same as using [editSensorConfig] with all parameters set.
  ///
  /// Example:
  /// ```dart
  /// // Changes the time interval of the accelerometer to 1 second, the target
  /// // precision to 2 and the target unit to m/s^2.
  /// SensorManager().setSensorConfig(
  ///   SensorId.accelerometer,
  ///   SensorConfig(
  ///     targetUnit: Unit.metersPerSecondSquared,
  ///     targetPrecision: 2,
  ///     timeInterval: Duration(seconds: 1),
  ///   ),
  /// );
  /// ```
  Future<SensorTaskResult> setSensorConfig(
    SensorId sensorId,
    SensorConfig config,
  ) =>
      editSensorConfig(
        sensorId,
        targetUnit: config.targetUnit,
        targetPrecision: config.targetPrecision,
        timeInterval: config.timeInterval,
      );
}

/// Class to convert a stream to a stream controller.
/// Contains both the controller and the base subscription to the initial
/// stream.
class _StreamPair {
  final StreamController<SensorData> _streamController =
      StreamController<SensorData>.broadcast();
  late final StreamSubscription<SensorData> _streamSubscription;

  ///Constructor to convert a regular stream to a stream controller.
  _StreamPair(Stream<SensorData> baseStream) {
    _streamSubscription = baseStream.listen((event) {
      if (!_streamController.isClosed || !_streamController.isPaused) {
        _streamController.add(event);
      }
    });
  }
}

/// Wrapper class for [SensorConfig].
///
/// This class is used to change the [SensorConfig] of a sensor while tracking.
class SensorConfigWrapper {
  /// [SensorConfig] to be wrapped.
  SensorConfig sensorConfig;

  /// Creates a new [SensorConfigWrapper] object.
  SensorConfigWrapper(
    this.sensorConfig,
  );
}
