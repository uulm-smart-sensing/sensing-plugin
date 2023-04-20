import '../../sensing_plugin.dart';
import '../generated/api_sensor_manager.dart';
import 'unit.dart';

/// Processed [SensorData].
class ProcessedSensorData<T extends Unit<T>> {
  /// Processed sensor data
  final List<double> data;

  /// Maximum precision of all values in [data]
  final int maxPrecision;

  /// Unit of all values in [data]
  final Unit<T> unit;

  /// Timestamp when the value in [data] were meassured.
  final DateTime timestamp;

  /// Creates a new [ProcessedSensorData] object.
  const ProcessedSensorData({
    required this.data,
    required this.maxPrecision,
    required this.unit,
    required this.timestamp,
  });
}
