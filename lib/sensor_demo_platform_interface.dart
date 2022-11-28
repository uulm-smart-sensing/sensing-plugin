import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sensor_demo_pigeon.dart';
import 'sensor_event.dart';

abstract class SensorDemoPlatform extends PlatformInterface {
  SensorDemoPlatform() : super(token: _token);

  static final Object _token = Object();

  static SensorDemoPlatform _instance = PigeonSensorDemo();

  static SensorDemoPlatform get instance => _instance;

  static set instance(SensorDemoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Register a sensor update request.
  Future<Stream<SensorEvent>> sensorUpdates({required int sensorId, Duration? interval});

  /// Check if the sensor is available in the device.
  Future<bool> isSensorAvailable(int sensorId);

  /// Updates the interval between updates for an specific sensor.
  Future<bool> updateSensorInterval(int sensorId, Duration newInterval);
}
