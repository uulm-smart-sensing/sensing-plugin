import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/preprocessing/preprocessor.dart';
import 'package:sensing_plugin/src/preprocessing/sensor_config.dart';

void main() {
  test('When null values are passed then they are filtered out', () {
    var preprocessor = Preprocessor(
      config: const SensorConfig(
        targetUnit: Unit.unitless,
        targetPrecision: 1,
        timeInterval: Duration(seconds: 1),
      ),
    );

    var sensorData = SensorData(
      data: [
        null,
      ],
      maxPrecision: 1,
      unit: Unit.unitless,
    );
    var preprocessedData = preprocessor.processData(sensorData);
    expect(preprocessedData, isEmpty);
  });

  test('When values are passed then they are preprocessed', () {
    var preprocessor = Preprocessor(
      config: const SensorConfig(
        targetUnit: Unit.celsius,
        targetPrecision: 1,
        timeInterval: Duration(seconds: 1),
      ),
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
    );
    var preprocessedData = preprocessor.processData(sensorData);
    expect(preprocessedData, isNotEmpty);
    expect(preprocessedData, equals([37.8, 43.3, 48.9]));
  });
}