import 'package:flutter/foundation.dart' show immutable;

import 'preprocessing/unit.dart';

/// Configuration of a sensor's output data.
///
/// [T] is the unit category of the unit of this [SensorConfig].
@immutable
class SensorConfig<T extends Unit<T>> {
  /// The [Unit] that the output values should have.
  final Unit<T> targetUnit;

  /// The number of decimal places which the output values should have.
  final int targetPrecision;

  /// The interval at which the sensor should send values.
  final Duration timeInterval;

  /// Creates a [SensorConfig] object.
  const SensorConfig({
    required this.targetUnit,
    required this.targetPrecision,
    required this.timeInterval,
  });

  /// Creates a copy of this [SensorConfig] with optional changed properties.
  ///
  /// If a parameter is not null the value of this [SensorConfig] will be
  /// overwritten, otherwise (if the value is null or not specified) the value
  /// will not be overwritten.
  ///
  /// Example:
  /// ```dart
  /// var config = const SensorConfig(
  ///   targetUnit: Unit.celsius,
  ///   targetPrecision: 2,
  ///   timeInterval: Duration(seconds: 2),
  /// );
  ///
  /// var copy = config.copyWith(targetUnit: Unit.kelvin, timeInterval: null);
  /// // copy is
  /// // SensorConfig(
  /// //   targetUnit: Unit.kelvin,
  /// //   targetPrecision: 2,
  /// //   timeInterval: Duration(seconds: 2),
  /// // )
  /// ```
  SensorConfig copyWith({
    Unit<T>? targetUnit,
    int? targetPrecision,
    Duration? timeInterval,
  }) =>
      SensorConfig<T>(
        targetUnit: targetUnit ?? this.targetUnit,
        targetPrecision: targetPrecision ?? this.targetPrecision,
        timeInterval: timeInterval ?? this.timeInterval,
      );
}
