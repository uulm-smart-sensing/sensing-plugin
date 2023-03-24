import 'dart:math' show pi;

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../generated/api_sensor_manager.dart' show Unit;

/// Conversion methods for each unit.
@visibleForTesting
final unitConversionMethods = <Unit, double Function(double, Unit, Unit)>{
  Unit.metersPerSecondSquared: _convertAcceleration,
  Unit.gravitationalForce: _convertAcceleration,
  Unit.radiansPerSecond: _convertAngularVelocity,
  Unit.degreesPerSecond: _convertAngularVelocity,
  Unit.microTeslas: _convertMagneticFluxDensity,
  Unit.radians: _convertAngle,
  Unit.degrees: _convertAngle,
  Unit.hectoPascal: _convertPressure,
  Unit.kiloPascal: _convertPressure,
  Unit.bar: _convertPressure,
  Unit.celsius: _convertTemperature,
  Unit.fahrenheit: _convertTemperature,
  Unit.kelvin: _convertTemperature,
  Unit.unitless: _convertMiscellaneous,
};

/// Converts the [Unit] of the passed [value] to the [targetUnit].
///
/// It is assumed that [value] has the unit [sourceUnit].
/// If the [sourceUnit] can't be converted to the [targetUnit], e.g.
/// [sourceUnit] is an acceleration unit and [targetUnit] is a temperature unit,
/// an [UnsupportedUnitException] is thrown.
///
/// Example usage:
/// ```dart
/// var result = convertUnit(
///   value: 21,
///   sourceUnit: Unit.celsius,
///   targetUnit: Unit.fahrenheit,
/// );
/// print("21 °C is $result °F");
/// ```
/// will result in
/// ```text
/// 21 °C is 69.8 °F
/// ```
double convertUnit({
  required double value,
  required Unit sourceUnit,
  required Unit targetUnit,
}) {
  var conversionMethod = unitConversionMethods[sourceUnit]!;
  return conversionMethod.call(value, sourceUnit, targetUnit);
}

// Acceleration in Gs = Acceleration in m/s^2 / gravity on earth
const _gravityEarth = 9.80665;
double _metersPerSecondSquaredToGravitationalForce(value) =>
    value / _gravityEarth;
double _gravitationalForceToMetersPerSecondSquared(value) =>
    value * _gravityEarth;

double _convertAcceleration(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInMetersPerSecondSquared;
  switch (sourceUnit) {
    case Unit.metersPerSecondSquared:
      valueInMetersPerSecondSquared = value;
      break;
    case Unit.gravitationalForce:
      valueInMetersPerSecondSquared =
          _gravitationalForceToMetersPerSecondSquared(value);
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.metersPerSecondSquared:
      valueInTargetUnit = valueInMetersPerSecondSquared;
      break;
    case Unit.gravitationalForce:
      valueInTargetUnit = _metersPerSecondSquaredToGravitationalForce(
        valueInMetersPerSecondSquared,
      );
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

// Angle in Degrees = Angle in Radians * PI / 180
// Since only the numerator changes, the same is true for angular velocity.
double _radiansToDegrees(value) => value * 180 / pi;
double _degreesToRadians(value) => value / 180 * pi;

double _convertAngularVelocity(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInRadiansPerSecond;
  switch (sourceUnit) {
    case Unit.radiansPerSecond:
      valueInRadiansPerSecond = value;
      break;
    case Unit.degreesPerSecond:
      valueInRadiansPerSecond = _degreesToRadians(value);
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.radiansPerSecond:
      valueInTargetUnit = valueInRadiansPerSecond;
      break;
    case Unit.degreesPerSecond:
      valueInTargetUnit = _radiansToDegrees(valueInRadiansPerSecond);
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

double _convertMagneticFluxDensity(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInMicroTeslas;
  switch (sourceUnit) {
    case Unit.microTeslas:
      valueInMicroTeslas = value;
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.microTeslas:
      valueInTargetUnit = valueInMicroTeslas;
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

double _convertAngle(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInRadians;
  switch (sourceUnit) {
    case Unit.radians:
      valueInRadians = value;
      break;
    case Unit.degrees:
      valueInRadians = _degreesToRadians(value);
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.radians:
      valueInTargetUnit = valueInRadians;
      break;
    case Unit.degrees:
      valueInTargetUnit = _radiansToDegrees(valueInRadians);
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

// Pressure in Bar = Pressure in hecto Pascal / 1000
double _hectoPascalToBar(value) => value / 1000;
double _barToHectoPascal(value) => value * 1000;

// Pressure in Bar = Pressure in kilo Pascal / 100
double _kiloPascalToBar(value) => value / 100;
double _barToKiloPascal(value) => value * 100;

// Pressure in hecto Pascal = Pressure in kilo Pascal * 0.1
double _hectoPascalToKiloPascal(value) => value / 10;
double _kiloPascalToHectoPascal(value) => value * 10;

double _convertPressure(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInHectoPascal;
  switch (sourceUnit) {
    case Unit.hectoPascal:
      valueInHectoPascal = value;
      break;
    case Unit.kiloPascal:
      valueInHectoPascal = _kiloPascalToHectoPascal(value);
      break;
    case Unit.bar:
      valueInHectoPascal = _barToHectoPascal(value);
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.hectoPascal:
      valueInTargetUnit = valueInHectoPascal;
      break;
    case Unit.kiloPascal:
      valueInTargetUnit = _hectoPascalToKiloPascal(valueInHectoPascal);
      break;
    case Unit.bar:
      valueInTargetUnit = _hectoPascalToBar(valueInHectoPascal);
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

// Temperature in Kelvin = Temperature in Celsius + 273.15
double _celsiusToKelvin(value) => value + 273.15;
double _kelvinToCelsius(value) => value - 273.15;

// Temperature in Fahrenheit = Temperature in Celsius * 1.8 + 32
double _cesliusToFahrenheit(value) => value * 1.8 + 32;
double _fahrenheitToCelsius(value) => (value - 32) / 1.8;

double _convertTemperature(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  double valueInCelsius;
  switch (sourceUnit) {
    case Unit.celsius:
      valueInCelsius = value;
      break;
    case Unit.fahrenheit:
      valueInCelsius = _fahrenheitToCelsius(value);
      break;
    case Unit.kelvin:
      valueInCelsius = _kelvinToCelsius(value);
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  double valueInTargetUnit;
  switch (targetUnit) {
    case Unit.celsius:
      valueInTargetUnit = valueInCelsius;
      break;
    case Unit.fahrenheit:
      valueInTargetUnit = _cesliusToFahrenheit(valueInCelsius);
      break;
    case Unit.kelvin:
      valueInTargetUnit = _celsiusToKelvin(valueInCelsius);
      break;
    default:
      throw UnsupportedUnitException(targetUnit);
  }

  return valueInTargetUnit;
}

/// Miscellaneous units have no other unit to convert to, so [sourceUnit] and
/// [targetUnit] must be the same.
double _convertMiscellaneous(
  double value,
  Unit sourceUnit,
  Unit targetUnit,
) {
  if (sourceUnit != targetUnit) {
    throw UnsupportedUnitException(targetUnit);
  }

  double valueInTargetUnit;
  switch (sourceUnit) {
    case Unit.unitless:
      valueInTargetUnit = value;
      break;
    default:
      throw UnsupportedUnitException(sourceUnit);
  }

  return valueInTargetUnit;
}

/// Exception thrown when a [Unit] is not supported in the current context.
class UnsupportedUnitException implements Exception {
  final Unit _unit;

  /// Creates a [UnsupportedUnitException] object.
  UnsupportedUnitException(this._unit);

  @override
  String toString() =>
      "The unit $_unit is not supported in the current context";
}
