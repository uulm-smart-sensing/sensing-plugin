import '../generated/api_sensor_manager.dart';
import '../units/unit.dart';

/// Processed [SensorData].
class ProcessedSensorData {
  /// Processed sensor data
  final List<double> data;

  /// Maximum precision of all values in [data]
  final int maxPrecision;

  /// Unit of all values in [data]
  final Unit unit;

  /// Timestamp when the values in [data] were measured.
  final DateTime timestamp;

  /// Creates a new [ProcessedSensorData] object.
  const ProcessedSensorData({
    required this.data,
    required this.maxPrecision,
    required this.unit,
    required this.timestamp,
  });
}
