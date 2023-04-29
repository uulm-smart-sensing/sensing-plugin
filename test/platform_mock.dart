import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/sensor_config.dart';
import 'package:sensing_plugin/src/sensor_manager_api_platform.dart';

class MockSensorManagerApiPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        SensorManagerApiPlatform {
  final _usedSensors = <SensorId>[];

  @override
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) {
    if (timeIntervalInMilliseconds < 20) {
      return Future(() => SensorTaskResult.warning);
    }
    return Future(() => SensorTaskResult.success);
  }

  @override
  Future<InternalSensorInfo> getInternalSensorInfo(SensorId id) {
    switch (id) {
      case SensorId.accelerometer:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.metersPerSecondSquared,
            accuracy: SensorAccuracy.high,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.gyroscope:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.radiansPerSecond,
            accuracy: SensorAccuracy.high,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.magnetometer:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.microTeslas,
            accuracy: SensorAccuracy.high,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.orientation:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.degrees,
            accuracy: SensorAccuracy.high,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.linearAcceleration:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.metersPerSecondSquared,
            accuracy: SensorAccuracy.high,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.barometer:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.hectoPascal,
            accuracy: SensorAccuracy.low,
            timeIntervalInMilliseconds: 100,
          ),
        );
      case SensorId.thermometer:
        return Future(
          () => InternalSensorInfo(
            unit: SensorUnit.celsius,
            accuracy: SensorAccuracy.medium,
            timeIntervalInMilliseconds: 100,
          ),
        );
    }
  }

  @override
  Future<bool> isSensorAvailable(SensorId id) {
    switch (id) {
      case SensorId.accelerometer:
      case SensorId.gyroscope:
      case SensorId.magnetometer:
      case SensorId.orientation:
      case SensorId.linearAcceleration:
        return Future(() => true);
      case SensorId.barometer:
      case SensorId.thermometer:
        return Future(() => false);
    }
  }

  @override
  Future<bool> isSensorUsed(SensorId id) =>
      Future(() => _usedSensors.contains(id));

  @override
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) {
    if (id == SensorId.thermometer) {
      return Future(() => SensorTaskResult.failure);
    }

    if (_usedSensors.contains(id)) {
      return Future(() => SensorTaskResult.alreadyTrackingSensor);
    }

    _usedSensors.add(id);
    return changeSensorTimeInterval(
      id: id,
      timeIntervalInMilliseconds: config.timeInterval.inMilliseconds,
    );
  }

  @override
  Future<SensorTaskResult> stopSensorTracking(SensorId id) {
    if (_usedSensors.contains(id)) {
      _usedSensors.remove(id);
      return Future(() => SensorTaskResult.success);
    }

    return Future(() => SensorTaskResult.notTrackingSensor);
  }
}
