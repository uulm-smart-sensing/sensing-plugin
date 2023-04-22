import '../generated/api_sensor_manager.dart' show InternalSensorData;
import '../sensor_config.dart';
import '../units/unit.dart';
import 'precision_converter.dart';
import 'sensor_data.dart';

/// Processes the passed [sensorData] object according to the passed
/// [sensorConfig] and returns the result as [SensorData].
///
/// The following operations are performed on all **non-null** elements in
/// [InternalSensorData.data]:
/// - converting the unit from [InternalSensorData.unit]
/// to [SensorConfig.targetUnit]
/// - converting the precision to [SensorConfig.targetPrecision]
/// - null values are omitted
///
/// [SensorData.unit] and [SensorData.maxPrecision] are set to
/// [SensorConfig.targetUnit] and [SensorConfig.targetPrecision] of the passed
/// [sensorConfig].
///
/// Examples:
/// ```dart
/// var config = const SensorConfig(
///   targetUnit: Temperature.celsius,
///   targetPrecision: 1,
///   timeInterval: Duration(seconds: 1),
/// );
///
/// var sensorData = InternalSensorData(
///   data: [
///     100,
///     null,
///     110,
///     120,
///   ],
///   maxPrecision: 2,
///   unit: SensorUnit.fahrenheit,
///   timestampInMicroseconds: 123456789,
/// );
/// var processedData = processData(
///   sensorData: sensorData,
///   sensorConfig: config,
/// );
/// // processedData is:
/// // ProcessedSensorData(
/// //   data: [37.8, 43.3, 48.9],
/// //   maxPrecision: 1,
/// //   unit: Temperature.celsius,
/// //   timestamp: DateTime.fromMicrosecondsSinceEpoch(123456789, isUtc: true),
/// // )
/// ```
/// It is also possible to use for processing streams of sensor data e.g:
/// ```dart
/// sensorDataStream.map(
///   (sensorData) => processData(sensorData, sensorConfig),
/// ).listen(...);
/// ```
SensorData processData(
  InternalSensorData sensorData,
  SensorConfig sensorConfig,
) =>
    SensorData(
      data: sensorData.data
          .whereType<double>()
          .map(
            (value) => sensorUnitToUnit(sensorData.unit)
                .convertTo(sensorConfig.targetUnit, value),
          )
          .map(
            (value) => convertPrecision(
              value: value,
              targetPrecision: sensorConfig.targetPrecision,
            ),
          )
          .toList(),
      maxPrecision: sensorConfig.targetPrecision,
      unit: sensorConfig.targetUnit,
      timestamp: DateTime.fromMicrosecondsSinceEpoch(
        sensorData.timestampInMicroseconds,
        isUtc: true,
      ),
    );
