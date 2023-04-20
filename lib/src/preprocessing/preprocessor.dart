import '../generated/api_sensor_manager.dart' show SensorData, SensorUnit;
import '../sensor_config.dart';
import 'precision_converter.dart';
import 'processed_sensor_data.dart';
import 'unit.dart';

/// Processes the passed [sensorData] object according to the passed
/// [sensorConfig] and returns the result as [ProcessedSensorData].
///
/// The following operations are performed on all **non-null** elements in
/// [SensorData.data]:
/// - converting the unit from [SensorData.unit] to [SensorConfig.targetUnit]
/// - converting the precision to [SensorConfig.targetPrecision]
/// - null values are omitted
///
/// [ProcessedSensorData.unit] and [ProcessedSensorData.maxPrecision] are set to
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
/// var sensorData = SensorData(
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
/// );
/// ```
ProcessedSensorData processData<T extends Unit<T>>(
  SensorData sensorData,
  SensorConfig<T> sensorConfig,
) =>
    ProcessedSensorData<T>(
      data: sensorData.data
          .whereType<double>()
          .map(
            (value) => _sensorUnitToUnit(sensorData.unit)
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

Unit _sensorUnitToUnit(SensorUnit sensorUnit) {
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
    case SensorUnit.hectoPascal:
      return Pressure.hectoPascal;
    case SensorUnit.kiloPascal:
      return Pressure.kiloPascal;
    case SensorUnit.celsius:
      return Temperature.celsius;
  }
}
