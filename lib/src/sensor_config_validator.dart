import 'generated/api_sensor_manager.dart';
import 'units/unit.dart';

/// Variable for validating minPrecision
const configValidatorMinPrecision = 0;

/// Variable for validating maxPrecision
const configValidatorMaxPrecision = 10;

/// Checks whether the passed [precision] is valid. It is valid if it is
/// between [configValidatorMinPrecision] and [configValidatorMaxPrecision].
bool validatePrecision(int precision) =>
    precision >= configValidatorMinPrecision &&
    precision <= configValidatorMaxPrecision;

/// Variable for validating TimeInterval
/// one week, 23 hours, 59 minutes and 59 seconds is equivalent to
/// [maxTimeInterval]
const maxTimeInterval = 691199000;

/// Checks whether the passed [timeIntervalInMilliseconds] is valid. It is valid
/// if the interval is between 10 ms and one week, 23 hours, 59 minutes and 59
/// seconds. The minimum was not 0 ms because a sensor can hardly have such high
/// frequencies.
bool validateInterval(int timeIntervalInMilliseconds) =>
    timeIntervalInMilliseconds >= 10 &&
    timeIntervalInMilliseconds <= maxTimeInterval;

/// Checks whether the passed [unit] is valid for the passed [sensorId].
bool validateUnit({
  required Unit unit,
  required SensorId sensorId,
}) {
  switch (sensorId) {
    case SensorId.accelerometer:
      return unit.runtimeType == Acceleration;
    case SensorId.linearAcceleration:
      return unit.runtimeType == Acceleration;
    case SensorId.gyroscope:
      return unit.runtimeType == AngularVelocity;
    case SensorId.magnetometer:
      return unit.runtimeType == MagneticFluxDensity;
    case SensorId.orientation:
      return unit.runtimeType == Angle;
    case SensorId.barometer:
      return unit.runtimeType == Pressure;
    case SensorId.thermometer:
      return unit.runtimeType == Temperature;
  }
}
