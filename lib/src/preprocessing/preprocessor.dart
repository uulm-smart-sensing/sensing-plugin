import '../generated/api_sensor_manager.dart' show SensorData;
import '../sensor_config.dart';
import 'precision_converter.dart';
import 'unit_converter.dart';

/// Processes the [SensorData.data] of the passed [sensorData] object
/// according to the passed [sensorConfig].
///
/// The following operations are performed on all non-null elements in
/// [SensorData.data]:
/// - converting the unit from [SensorData.unit] to [SensorConfig.targetUnit]
/// - converting the precision to [SensorConfig.targetPrecision]
///
/// [SensorData.unit] and [SensorData.maxPrecision] are set to
/// [SensorConfig.targetUnit] and [SensorConfig.targetPrecision] of the passed
/// [sensorConfig].
///
/// The passed [sensorData] object is adjusted accordingly and returned.
///
/// Examples:
/// ```dart
/// var config = const SensorConfig(
///   targetUnit: Unit.celsius,
///   targetPrecision: 1,
///   timeInterval: Duration(seconds: 1),
/// );
///
/// var sensorData = SensorData(
///   data: [
///     100,
///     null,
///     110,
///     120,
///   ],
///   maxPrecision: 2,
///   unit: Unit.fahrenheit,
///   timestampInMicroseconds: 123456789,
/// );
/// var processedData = processData(
///   sensorData: sensorData,
///   sensorConfig: config,
/// );
/// // processedData is:
/// // SensorData(
/// //   data: [37.8, 43.3, 48.9],
/// //   maxPrecision: 1,
/// //   unit: Unit.celsius,
/// //   timestampInMicroseconds: 123456789,
/// // )
/// ```
/// It is also possible to use for processing streams of sensor data e.g:
/// ```dart
/// sensorDataStream.
///   .map(preprocessor.processData)
///   .listen(...)
/// ```
SensorData processData({
  required SensorData sensorData,
  required SensorConfig sensorConfig,
}) {
  sensorData
    ..data = sensorData.data
        .whereType<double>()
        .map(
          (value) => convertUnit(
            value: value,
            sourceUnit: sensorData.unit,
            targetUnit: sensorConfig.targetUnit,
          ),
        )
        .map(
          (value) => convertPrecision(
            value: value,
            targetPrecision: sensorConfig.targetPrecision,
          ),
        )
        .toList()
    ..unit = sensorConfig.targetUnit
    ..maxPrecision = sensorConfig.targetPrecision;
  return sensorData;
}
