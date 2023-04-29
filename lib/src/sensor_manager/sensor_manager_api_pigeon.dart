import '../../sensing_plugin.dart';
import '../generated/api_sensor_manager.dart';
import 'sensor_manager_api_platform.dart';

/// Default handler for delegating the calls from the [SensorManager] to
/// the platforms using pigeon, so the [SensorManagerApi].
///
/// The [SensorManager] do not provide the call directly to the native platforms
///  (iOS and Android) but request a "delegator" from the
/// [SensorManagerApiPlatform].instance. The default instance is the
/// [SensorManagerPigeonApi] which uses [SensorManagerApi] (= auto-generated
/// pigeon code) to call the sensor managers on the native platforms.
class SensorManagerPigeonApi extends SensorManagerApiPlatform {
  /// Checks whether the sensor with the passed [SensorId] is available.
  @override
  Future<bool> isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Checks whether the sensor with the passed [SensorId] is currently used.
  @override
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Starts tracking of the sensor with the passed [SensorId].
  @override
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) async =>
      SensorManagerApi()
          .startSensorTracking(id, config.timeInterval.inMilliseconds)
          .then((value) => value.state);

  /// Stops tracking of the sensor with the passed [SensorId].
  @override
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async =>
      SensorManagerApi().stopSensorTracking(id).then((value) => value.state);

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  @override
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) async =>
      SensorManagerApi()
          .changeSensorTimeInterval(id, timeIntervalInMilliseconds)
          .then((value) => value.state);

  /// Retrieves information about the sensor with the passed [SensorId].
  @override
  Future<InternalSensorInfo> getInternalSensorInfo(SensorId id) =>
      SensorManagerApi().getSensorInfo(id);

  /// [InternalSensorData] isn't used in any method but returned
  ///  via the event channel.
  ///
  /// For the class to be generated on the platforms it must be referenced in at
  /// least one method.
  // ignore: unused_element
  void _dummyMethod(InternalSensorData data) {
    throw UnimplementedError('`_dummyMethod` is not implemented yet');
  }
}
