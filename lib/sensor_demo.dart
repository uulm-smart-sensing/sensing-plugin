import 'sensor_demo_platform_interface.dart';
import 'sensor_event.dart';

class SensorDemo {
  Future<bool> isSensorAvailable(int sensorId) => SensorDemoPlatform.instance.isSensorAvailable(sensorId);

  Future<bool> updateSensorInterval(int sensorId, Duration newInterval) =>
      SensorDemoPlatform.instance.updateSensorInterval(sensorId, newInterval);

  Future<Stream<SensorEvent>> sensorUpdates({required int sensorId, Duration? interval}) =>
      SensorDemoPlatform.instance.sensorUpdates(sensorId: sensorId, interval: interval);
}
