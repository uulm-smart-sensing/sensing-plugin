part of unit;

/// Angular velocity unit category.
///
/// Used for sensors with the [SensorId] [SensorId.gyroscope].
enum AngularVelocity implements Unit<AngularVelocity> {
  /// Angular velocity in radians per second (rad/s).
  radiansPerSecond(1, "rad/s", "radians/s"),

  /// Angular velocity in degrees per second (deg/s).
  degreesPerSecond(180 / pi, "deg/s", "degrees/s"),

  /// Angular velocity in degrees per minute (deg/m).
  degreesPerMinute(10800 / pi, "deg/m", "degrees/m"),

  /// Angular velocity in degrees per hour (deg/h).
  degreesPerHour(648000 / pi, "deg/h", "degrees/h"),

  /// Angular velocity in revolutions per minute (RPM).
  revolutionPerMinute(60 / (2 * pi), "RPM", "RPM"),

  /// Angular velocity in revolutions per hour (RPH).
  revolutionPerHour(3600 / (2 * pi), "RPH", "RPH");

  /// Creates a new enum value for [AngularVelocity].
  const AngularVelocity(
    this._factor,
    this._shortDisplayText,
    this._longDisplayText,
  );

  final num _factor;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(AngularVelocity targetUnit, double value) =>
      value / _factor * targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
