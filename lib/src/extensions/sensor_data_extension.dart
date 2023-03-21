import '../generated/api_sensor_manager.dart';

/// Extension methods for [SensorData].
extension SensorDataExtension on SensorData {
  /// Copies this [SensorData] object and replaces each object variable with the
  /// according parameter if the parameter is not null.
  ///
  /// Example:
  /// ```dart
  /// var sensorData = SensorData(
  ///   data: [1, 2, 3],
  ///   maxPrecision: 2,
  ///   unit: Unit.celsius,
  /// );
  /// var copy = sensorData.copyWith(data: [2, 3, 6], unit: Unit.fahrenheit);
  /// // copy is:
  /// // SensorData(
  /// //   data: [2, 3, 6],
  /// //   maxPrecision: 2,
  /// //   unit: Unit.fahrenheit,
  /// // )
  /// ```
  SensorData copyWith({
    List<double?>? data,
    int? maxPrecision,
    Unit? unit,
  }) =>
      SensorData(
        data: data ?? this.data,
        maxPrecision: maxPrecision ?? this.maxPrecision,
        unit: unit ?? this.unit,
      );
}
