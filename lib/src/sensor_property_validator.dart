import 'generated/api_sensor_manager.dart' show Unit, SensorId;

/// [SensorPropertyValidator] checks if the properties defined for a sensor
/// (tracking) is valid , so there are no errors when tracking a sensor
class SensorPropertyValidator {
  /// Checks if the precision is valid
  ///
  /// Example usage:
  /// ```dart
  /// var result = checkPrecision(9);
  /// ```
  /// will result in
  /// ```text
  /// true
  /// ```
  bool checkPrecision(int precision) => precision < 10 && precision >= 0;

  /// Checks if the timeInterval is valid
  ///
  /// Example usage:
  /// ```dart
  /// var result = checktimeInterval(9);
  /// ```
  /// will result in
  /// ```text
  /// true
  /// ```
  bool checkTimeInterval(int interval) =>
      interval < 31536000000 && interval >= 0;

  /// Checks if the unit is valid
  ///
  /// Example usage:
  /// ```dart
  /// var result = checkUnit(Accelerometer,MetersPerSecondSquared);
  /// ```
  /// will result in
  /// ```text
  /// true
  /// ```
  bool checkUnit(SensorId id, Unit unit) {
    switch (id) {
      case SensorId.accelerometer:
        return unit == Unit.metersPerSecondSquared ||
            unit == Unit.gravitationalForce;
      case SensorId.gyroscope:
        return unit == Unit.radiansPerSecond || unit == Unit.degreesPerSecond;
      case SensorId.magnetometer:
        return unit == Unit.microTeslas;
      case SensorId.orientation:
        return unit == Unit.radians || unit == Unit.degrees;
      case SensorId.linearAcceleration:
        return unit == Unit.metersPerSecondSquared ||
            unit == Unit.gravitationalForce;
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
}
