import 'package:flutter/foundation.dart' show immutable;

import '../generated/api_sensor_manager.dart' show Unit;

/// Configuration of a sensor's output data.
@immutable
class SensorConfig {
  /// The [Unit] that the output values should have.
  final Unit targetUnit;

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
}
