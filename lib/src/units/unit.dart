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
