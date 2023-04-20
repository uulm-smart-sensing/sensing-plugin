import 'dart:math';

import '../generated/api_sensor_manager.dart';

/// Unit of sensor output data.
///
/// [T] should be an enum implementing [Unit].
/// A unit category enum implementing [Unit] should pass itself as [T].
/// e.g. For the unit category "temperature":
/// ```dart
/// enum Temperature implements Unit<Temperature> {
/// ...
/// double convertTo(Temperature targetUnit, double value) => ...
/// ```
///
/// In most cases it is sufficient to define a factor for each enum value to
/// calculate the ratio to each other. If the valence of a unit is not
/// proportional to each other, you may need to use an offset.
abstract class Unit<T extends Unit<T>> {
  /// Converts a [value] of this unit category [T] to a target unit of the same
  /// unit category.
  double convertTo(T targetUnit, double value);

  /// Provides a text display for this [Unit].
  ///
  /// If [isShort] is true, a short version will be returned, which can be used
  /// when little space is available. Otherwise the default (and in most cases)
  /// longer version will be returned.
  String toTextDisplay({bool isShort = false});
}

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

/// Angle unit category.
///
/// Used for sensors with the [SensorId] [SensorId.orientation].
enum Angle implements Unit<Angle> {
  /// Angle in radians (rad).
  radians(1, "rad", "radians"),

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
      value * _factor / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}

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

  /// Angular velocity in revolutions per second (RPS).
  revolutionPerMinute(60 / (2 * pi), "RPS", "RPS"),

  /// Angular velocity in revolutions per minute (RPM).
  revolutionPerHour(3600 / (2 * pi), "RPM", "RPM");

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
      value * _factor / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}

/// Magnetic flux density unit category.
///
/// Used for sensors with the [SensorId] [SensorId.magnetometer].
enum MagneticFluxDensity implements Unit<MagneticFluxDensity> {
  /// Magnetic flux density in tesla (T).
  tesla(1, "T", "Tesla"),

  /// Magnetic flux density in gauss (Gs).
  gauss(10000, "Gs", "Gauss"),

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
      value * _factor / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}

/// Temperature unit category.
///
/// Used for sensors with the [SensorId] [SensorId.thermometer].
enum Temperature implements Unit<Temperature> {
  /// Temperature in kelvin (K).
  kelvin(1, 0, "K", "Kelvin"),

  /// Temperature in celsius (°C).
  celsius(1, 273.15, "°C", "Celsius"),

  /// Temperature in rankine (°R).
  rankine(5 / 9, 0, "°R", "Rankine"),

  /// Temperature in fahrenheit (°F).
  fahrenheit(5 / 9, 459.67, "°F", "Fahrenheit");

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
      value * _factor + _offset - targetUnit._offset / targetUnit._factor;

  @override
  String toTextDisplay({bool isShort = false}) =>
      isShort ? _shortDisplayText : _longDisplayText;
}
