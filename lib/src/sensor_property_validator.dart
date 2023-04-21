import 'generated/api_sensor_manager.dart' show Unit, SensorId;

/// Checks whether the passed [precision] is valid. It is valid if it is
/// between 0 and 10.
bool validatePrecision(int precision) => precision >= 0 && precision <= 10;

/// Variable for validating TimeInterval
/// one week, 23 hours, 59 minutes and 59 seconds is equivalent to
/// [maxTimeInterval]
const int maxTimeInterval = 691199000;

/// Checks whether the passed [interval] is valid.It is valid if the interval
/// is between 10 and one week, 23 hours, 59 minutes and 59 seconds.The
/// minimum was not 0 because a sensor can hardly have such high frequencies.
///
bool validateIntervalInMilliseconds(int interval) =>
    interval >= 10 && interval <= maxTimeInterval;

///Checks if the matching unit with the corresponding SensorId is the
///same category/compatible.
///
///For example a SensorId can be an accelerometer and the corresponding Unit is
///metersPerSecondSquared or gravitationalForce and if the given Unit does not
///match then [validateUnitCompatibility] returns false.
bool validateUnitCompatibility(SensorId id, Unit unit) {
  switch (id) {
    case SensorId.accelerometer:
    case SensorId.linearAcceleration:
      return unit == Unit.metersPerSecondSquared ||
          unit == Unit.gravitationalForce;
    case SensorId.gyroscope:
      return unit == Unit.radiansPerSecond || unit == Unit.degreesPerSecond;
    case SensorId.magnetometer:
      return unit == Unit.microTeslas;
    case SensorId.orientation:
      return unit == Unit.radians || unit == Unit.degrees;
    case SensorId.barometer:
      return unit == Unit.hectoPascal ||
          unit == Unit.kiloPascal ||
          unit == Unit.bar;
    case SensorId.thermometer:
      return unit == Unit.kelvin ||
          unit == Unit.fahrenheit ||
          unit == Unit.celsius;
  }
}
