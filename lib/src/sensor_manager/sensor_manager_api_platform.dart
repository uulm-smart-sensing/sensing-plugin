import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../sensing_plugin.dart';
import '../generated/api_sensor_manager.dart';
import 'sensor_manager_api_pigeon.dart';

/// Interface for handling the calls to the platform.
///
/// This means, the deriving classes need to implement the methods by adding the
/// calls to either the platforms (e. g. using Pigeon in
/// [SensorManagerPigeonApi]) or mocking the calls and responses to / from the
/// platform.
///
/// This additional "layer" is needed to mock the calls from the [SensorManager]
/// in the unit tests.
abstract class SensorManagerApiPlatform extends PlatformInterface {
  /// Constructs a AppUsagePlatform.
  SensorManagerApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static SensorManagerApiPlatform _instance = SensorManagerPigeonApi();

  /// The default instance of [SensorManagerApiPlatform] to use.
  ///
  /// Defaults to [SensorManagerPigeonApi].
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
      throw UnimplementedError('isSensorAvailable() has not been implemented.');

  /// Checks whether the sensor with the passed [SensorId] is currently used.
  Future<bool> isSensorUsed(SensorId id) async =>
      throw UnimplementedError('isSensorUsed() has not been implemented.');

  /// Starts tracking of the sensor with the passed [SensorId].
  Future<SensorTaskResult> startSensorTracking({
    required SensorId id,
    required SensorConfig config,
  }) async =>
      throw UnimplementedError(
        'startSensorTracking() has not been implemented.',
      );

  /// Stops tracking of the sensor with the passed [SensorId].
  Future<SensorTaskResult> stopSensorTracking(SensorId id) async =>
      throw UnimplementedError(
        'stopSensorTracking() has not been implemented.',
      );

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  Future<SensorTaskResult> changeSensorTimeInterval({
    required SensorId id,
    required int timeIntervalInMilliseconds,
  }) async =>
      throw UnimplementedError(
        'changeSensorTimeInterval() has not been implemented.',
      );

  /// Retrieves information about the sensor with the passed [SensorId].
  Future<InternalSensorInfo> getInternalSensorInfo(SensorId id) =>
      throw UnimplementedError(
        'getInternalSensorInfo() has not been implemented.',
      );

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
