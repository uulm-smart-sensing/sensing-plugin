library unit;

import 'dart:math';

import '../generated/api_sensor_manager.dart';

part 'acceleration.dart';
part 'angle.dart';
part 'angular_velocity.dart';
part 'magnetic_flux_density.dart';
part 'pressure.dart';
part 'temperature.dart';

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
/// proportional to other units in the same category, you may need to
/// use an offset (see [Temperature] for more information).
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

/// Retrieve the corresponding [Unit] for a given [SensorUnit].
Unit sensorUnitToUnit(SensorUnit sensorUnit) {
  switch (sensorUnit) {
    case SensorUnit.metersPerSecondSquared:
      return Acceleration.meterPerSecondSquared;
    case SensorUnit.gravitationalForce:
      return Acceleration.gravity;
    case SensorUnit.radiansPerSecond:
      return AngularVelocity.radiansPerSecond;
    case SensorUnit.microTeslas:
      return MagneticFluxDensity.microTesla;
    case SensorUnit.radians:
      return Angle.radians;
    case SensorUnit.degrees:
      return Angle.degrees;
    case SensorUnit.hectoPascal:
      return Pressure.hectoPascal;
    case SensorUnit.kiloPascal:
      return Pressure.kiloPascal;
    case SensorUnit.celsius:
      return Temperature.celsius;
  }
}
