// ignore_for_file: file_names

import 'package:flutter/foundation.dart' show immutable;

import 'generated/api_sensor_manager.dart' show SensorId, Unit;

/// The Class which is representing a Sensor
@immutable
class Sensor {
  /// The ID as a Typ from [SensorId].
  final SensorId id;

  /// This attributes holds the name from the Sensor.
  final String name;

  /// The [Unit] that the values should have.
  final Unit unit;

  /// The number of decimal places which the values should have.
  final int accuracy;

  /// The interval at which the sensor should send values.
  final Duration timeInterval;

  /// Creates a [Sensor] object.
  const Sensor({
    required this.id,
    required this.name,
    required this.unit,
    required this.accuracy,
    required this.timeInterval,
  });
}
