part of unit;

/// Pressure unit category.
///
/// Used for sensors with the [SensorId] [SensorId.barometer].
enum Pressure implements Unit<Pressure> {
  /// Pressure in bar (bar).
  bar(1, "bar", "bar"),

  /// Pressure in kilopascal (kPa).
  kiloPascal(100, "kPa", "kilopascal"),

  /// Pressure in hectopascal (hPa).
  hectoPascal(1000, "hPa", "hectopascal"),

  /// Pressure in pounds per square inch (psi).
  psi(14.5037738, "psi", "pounds/inch²"),

  /// Pressure in standard atmospheres (atm).
  atmosphere(0.9869233, "atm", "standard atmosphere"),

  /// Pressure in torr (Torr).
  torr(750.0616827, "mmHg", "Torr");

  /// Creates a new enum value for [Pressure].
  const Pressure(this._factor, this._shortDisplayText, this._longDisplayText);

  final num _factor;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(Pressure targetUnit, double value) =>
      value * targetUnit._factor / _factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
