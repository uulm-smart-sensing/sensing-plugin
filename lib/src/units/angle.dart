part of unit;

/// Angle unit category.
///
/// Used for sensors with the [SensorId] [SensorId.orientation].
enum Angle implements Unit<Angle> {
  /// Angle in radians (rad).
  radians(1, "rad", "radians"),

  /// Angle in turns (turn).
  /// Also known as revolution.
  turns(1 / (2 * pi), "tr", "turns"),

  /// Angle in gradians (gon).
  /// Also known as grad, gradian, or grade.
  gradian(200 / pi, "gon", "gradians"),

  /// Angle in degrees (deg).
  degrees(180 / pi, "deg", "degrees"),

  /// Angle in arcminutes (arcmin).
  arcminutes(10800 / pi, "'", "arcminutes"),

  /// Angle in arcseconds (arcsec).
  arcseconds(648000 / pi, '"', "arcseconds");

  /// Creates a new enum value for [Angle].
  const Angle(this._factor, this._shortDisplayText, this._longDisplayText);

  final num _factor;
  final String _shortDisplayText;
  final String _longDisplayText;

  @override
  double convertTo(Angle targetUnit, double value) =>
      value / _factor * targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
