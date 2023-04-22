import 'generated/api_sensor_manager.dart';
import 'units/unit.dart';

/// Basic information about a sensor.
///
/// The sensor will report data with an [accuracy] in the specified
/// [timeIntervalInMilliseconds]. The values will be in the fixed [unit].
class SensorInfo {
  SensorInfo(this.unit, this.accuracy, this.timeIntervalInMilliseconds);

  SensorInfo._fromInternal(InternalSensorInfo sensorInfo) {
    unit = sensorUnitToUnit(sensorInfo.unit);
    accuracy = sensorInfo.accuracy;
    timeIntervalInMilliseconds = sensorInfo.timeIntervalInMilliseconds;
  }

  late Unit unit;
  late SensorAccuracy accuracy;
  late int timeIntervalInMilliseconds;
}

SensorInfo sensorInfoFromInternal(InternalSensorInfo sensorInfo) =>
    SensorInfo._fromInternal(sensorInfo);
