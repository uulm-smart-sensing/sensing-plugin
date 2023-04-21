part of unit;

/// Acceleration unit category.
///
/// Used for sensors with the [SensorId]s [SensorId.accelerometer] and
/// [SensorId.linearAcceleration].
enum Acceleration implements Unit<Acceleration> {
  /// Acceleration in Gs = Acceleration in m/s^2 / gravity on earth.
  gravity(9.80665, "G"),

  /// Acceleration in m/s^2
  meterPerSecondSquared(1, "m/s²"),

  /// Acceleration in in/s^2
  inchPerSecondSquared(0.0254, "in/s²"),

  /// Acceleration in ft/s^2
  footPerSecondSquared(0.3048, "ft/s²");

  /// Creates a new enum value for [Acceleration].
  const Acceleration(this._factor, this._displayText);

  final num _factor;
  final String _displayText;

  @override
  double convertTo(Acceleration targetUnit, double value) =>
      value * _factor / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) => _displayText;
}
