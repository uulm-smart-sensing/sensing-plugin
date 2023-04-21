part of unit;

/// Magnetic flux density unit category.
///
/// Used for sensors with the [SensorId] [SensorId.magnetometer].
enum MagneticFluxDensity implements Unit<MagneticFluxDensity> {
  /// Magnetic flux density in tesla (T).
  tesla(1, "T", "Tesla"),

  /// Magnetic flux density in gauss (Gs).
  gauss(10000, "G", "Gauss"),

  /// Magnetic flux density in microtesla (μT).
  microTesla(1000000, "μT", "Microtesla");

  /// Creates a new enum value for [MagneticFluxDensity].
  const MagneticFluxDensity(
    this._factor,
    this._shortDisplayText,
    this._longDisplayText,
  );

  final num _factor;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(MagneticFluxDensity targetUnit, double value) =>
      value * _factor / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
