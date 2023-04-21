part of unit;

/// Acceleration unit category.
///
/// Used for sensors with the [SensorId]s [SensorId.accelerometer] and
/// [SensorId.linearAcceleration].
enum Acceleration implements Unit<Acceleration> {
  /// Acceleration in Gs = Acceleration in m/s^2 / gravity on earth.
  gravity(1 / 9.80665, "G", "standard gravity"),

  /// Acceleration in cm/s^2 (Gal).
  gal(100, "cm/s²", "Gal"),

  /// Acceleration in m/s^2
  meterPerSecondSquared(1, "m/s²", "meter/second²"),

  /// Acceleration in in/s^2
  inchPerSecondSquared(100 / 2.54, "in/s²", "inch/second²"),

  /// Acceleration in ft/s^2
  footPerSecondSquared(100 / 30.48, "ft/s²", "foot/second²");

  /// Creates a new enum value for [Acceleration].
  const Acceleration(
    this._factor,
    this._shortDisplayText,
    this._longDisplayText,
  );

  final num _factor;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(Acceleration targetUnit, double value) =>
      value / _factor * targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
