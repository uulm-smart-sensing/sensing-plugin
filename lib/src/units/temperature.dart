part of unit;

/// Temperature unit category.
///
/// Used for sensors with the [SensorId] [SensorId.thermometer].
enum Temperature implements Unit<Temperature> {
  /// Temperature in kelvin (K).
  kelvin(1, 0, "K", "Kelvin"),

  /// Temperature in celsius (°C).
  celsius(1, -273.15, "°C", "Celsius"),

  /// Temperature in rankine (°R).
  rankine(5 / 9, 0, "°R", "Rankine"),

  /// Temperature in fahrenheit (°F).
  fahrenheit(5 / 9, -459.67, "°F", "Fahrenheit");

  /// Creates a new enum value for [Temperature].
  const Temperature(
    this._factor,
    this._offset,
    this._shortDisplayText,
    this._longDisplayText,
  );

  final num _factor;
  final num _offset;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(Temperature targetUnit, double value) =>
      ((value - _offset) * _factor) / targetUnit._factor + targetUnit._offset;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
