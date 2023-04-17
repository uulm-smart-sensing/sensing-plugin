import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/preprocessing/preprocessor.dart';
import 'package:sensing_plugin/src/preprocessing/sensor_config.dart';

void main() {
  test('When null values are passed then they are filtered out', () {
    var config = const SensorConfig(
      targetUnit: Unit.unitless,
      targetPrecision: 1,
      timeInterval: Duration(seconds: 1),
    );

    var sensorData = SensorData(
      data: [
        null,
      ],
      maxPrecision: 1,
      unit: Unit.unitless,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(
      sensorData: sensorData,
      sensorConfig: config,
    );
    expect(preprocessedData.data, isEmpty);
  });

  test('When values are passed then they are preprocessed', () {
    var config = const SensorConfig(
      targetUnit: Unit.celsius,
      targetPrecision: 1,
      timeInterval: Duration(seconds: 1),
    );

    var sensorData = SensorData(
      data: [
        100,
        null,
        110,
        120,
      ],
      maxPrecision: 2,
      unit: Unit.fahrenheit,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(
      sensorData: sensorData,
      sensorConfig: config,
    );
    expect(preprocessedData.data, isNotEmpty);
    expect(preprocessedData.data, equals([37.8, 43.3, 48.9]));
  });

  test('When SensorData object is preprocessed, then unit stays the same', () {
    var config = const SensorConfig(
      targetUnit: Unit.celsius,
      targetPrecision: 1,
      timeInterval: Duration(seconds: 1),
    );

    var sensorData = SensorData(
      data: [
        1,
        2,
        3,
      ],
      maxPrecision: 5,
      unit: Unit.celsius,
      timestampInMicroseconds: 0,
    );

    var preprocessedData = processData(
      sensorData: sensorData,
      sensorConfig: config,
    );
    expect(preprocessedData.unit, equals(Unit.celsius));
  });

  test(
      'When sensor data is preprocessed, then output data has precision of '
      'sensor config', () {
    var config = const SensorConfig(
      targetUnit: Unit.celsius,
      targetPrecision: 1,
      timeInterval: Duration(seconds: 1),
    );

    var sensorData = SensorData(
      data: [
        1,
        2,
        3,
      ],
      maxPrecision: 2,
      unit: Unit.fahrenheit,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(
      sensorData: sensorData,
      sensorConfig: config,
    );
    expect(preprocessedData.maxPrecision, config.targetPrecision);
  });
}
