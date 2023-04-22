import 'generated/api_sensor_manager.dart';
import 'units/unit.dart';

/// Basic information about a sensor.
///
/// The sensor will report data with an [accuracy] in the specified
/// [timeIntervalInMilliseconds]. The values will be in the fixed [unit].
class SensorInfo {
  /// Creates a [SensorInfo] object with the specified [unit],
  /// [accuracy] and [timeIntervalInMilliseconds].
  SensorInfo(this.unit, this.accuracy, this.timeIntervalInMilliseconds);

  /// Creates a [SensorInfo] object from an [InternalSensorInfo] object
  /// by mapping the [SensorUnit] to a [Unit].
  SensorInfo._fromInternal(InternalSensorInfo sensorInfo) {
    unit = sensorUnitToUnit(sensorInfo.unit);
    accuracy = sensorInfo.accuracy;
    timeIntervalInMilliseconds = sensorInfo.timeIntervalInMilliseconds;
  }

  /// The unit of the sensors returned data.
  late Unit unit;

  /// The accuracy of the sensor.
  late SensorAccuracy accuracy;

  /// The time interval in milliseconds.
  late int timeIntervalInMilliseconds;
}

/// Converts [InternalSensorInfo] to [SensorInfo].
SensorInfo sensorInfoFromInternal(InternalSensorInfo sensorInfo) =>
    SensorInfo._fromInternal(sensorInfo);
