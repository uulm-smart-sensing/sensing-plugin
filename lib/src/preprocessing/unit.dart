import 'dart:math';

abstract class Unit {}

enum Acceleration implements Unit {
  gravity(9.80665),
  meterPerSecondSquared(1.0),
  inchPerSecondSquared(0.0254),
  footPerSecondSquared(0.3048);

  const Acceleration(this._factor);
  final num _factor;

  double convertTo(Acceleration targetUnit, double value) =>
      value * _factor / targetUnit._factor;
}

enum Angle implements Unit {
  radian(1.0),
  degree(180.0 / pi),
  arcminute(10800.0 / pi),
  arcsecond(648000.0 / pi);

  const Angle(this._factor);
  final num _factor;

  double convertTo(Angle targetUnit, double value) =>
      value * _factor / targetUnit._factor;
}

enum AngularVelocity implements Unit {
  radianPerSecond(1.0),
  degreePerSecond(180.0 / pi),
  degreePerMinute(10800.0 / pi),
  degreePerHour(648000.0 / pi),
  revolutionPerMinute(60.0 / (2 * pi)),
  revolutionPerHour(3600.0 / (2 * pi));

  const AngularVelocity(this._factor);
  final num _factor;

  double convertTo(AngularVelocity targetUnit, double value) =>
      value * _factor / targetUnit._factor;
}

enum MagneticFluxDensity implements Unit {
  tesla(1.0),
  gauss(10000.0),
  microTesla(1000000.0);

  const MagneticFluxDensity(this._factor);
  final num _factor;

  double convertTo(MagneticFluxDensity targetUnit, double value) =>
      value * _factor / targetUnit._factor;
}

enum Pressure implements Unit {
  bar(1.0),
  hectoPascal(100.0),
  psi(14.5037738),
  atmosphere(1.01325),
  torr(750.0616827);

  const Pressure(this._factor);
  final num _factor;

  double convertTo(Pressure targetUnit, double value) =>
      value * _factor / targetUnit._factor;
}

enum Temperature implements Unit {
  kelvin(1.0, 0.0),
  celsius(1.0, 273.15),
  fahrenheit(5 / 9, 459.67),
  rankine(5 / 9, 0.0);

  const Temperature(this._factor, this._offset);
  final num _factor;
  final num _offset;

  double convertTo(Temperature targetUnit, double value) =>
      value * _factor + _offset - targetUnit._offset / targetUnit._factor;
}

enum Misc implements Unit {
  unitless,
}
