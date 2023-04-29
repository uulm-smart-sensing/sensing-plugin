import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../sensing_plugin.dart';
import 'generated/api_sensor_manager.dart';

/// Interface for the platform and the methods need to be implemented by the
/// plugin API (used for mocking platform calls in unit tests)
abstract class SensorManagerApiPlatform extends PlatformInterface {
  /// Constructs a AppUsagePlatform.
  SensorManagerApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static SensorManagerApiPlatform _instance = SensorManager();

  /// The default instance of [SensorManagerApiPlatform] to use.
  ///
  /// Defaults to [SensorManager].
  static SensorManagerApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SensorManagerApiPlatform] when
  /// they register themselves.
  static set instance(SensorManagerApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks whether the sensor with the passed [SensorId] is available.
  Future<bool> isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);

  /// Checks whether the sensor with the passed [SensorId] is currently used.
  Future<bool> isSensorUsed(SensorId id) async =>
      SensorManagerApi().isSensorUsed(id);

  /// Starts tracking of the sensor with the passed [SensorId].
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) async =>
      SensorManagerApi()
          .startSensorTracking(id, config.timeInterval.inMilliseconds)
          .then((value) => value.state);

  /// Stops tracking of the sensor with the passed [SensorId].
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async =>
      SensorManagerApi().stopSensorTracking(id).then((value) => value.state);

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) async =>
      SensorManagerApi()
          .changeSensorTimeInterval(id, timeIntervalInMilliseconds)
          .then((value) => value.state);

  /// Retrieves information about the sensor with the passed [SensorId].
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
