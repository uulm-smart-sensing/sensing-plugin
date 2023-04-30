import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/preprocessing/preprocessor.dart';
import 'package:sensing_plugin/src/sensor_config.dart';
import 'package:sensing_plugin/src/sensor_manager/sensor_manager.dart';
import 'package:sensing_plugin/src/units/unit.dart';

void main() {
  test('When null values are passed then they are filtered out', () {
    var configWrapper = SensorConfigWrapper(
      const SensorConfig(
        targetUnit: Acceleration.gravity,
        targetPrecision: 1,
        timeInterval: Duration(seconds: 1),
      ),
    );

    var sensorData = InternalSensorData(
      data: [
        null,
      ],
      maxPrecision: 1,
      unit: SensorUnit.gravitationalForce,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(sensorData, configWrapper);
    expect(preprocessedData.data, isEmpty);
  });

  test('When values are passed then they are preprocessed', () {
    var configWrapper = SensorConfigWrapper(
      const SensorConfig(
        targetUnit: Temperature.fahrenheit,
        targetPrecision: 1,
        timeInterval: Duration(seconds: 1),
      ),
    );

    var sensorData = InternalSensorData(
      data: [
        100,
        null,
        110,
        120,
      ],
      maxPrecision: 2,
      unit: SensorUnit.celsius,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(sensorData, configWrapper);
    expect(preprocessedData.data, isNotEmpty);
    expect(preprocessedData.data, equals([212, 230, 248]));
  });

  test(
    '''When InternalSensorData object is preprocessed, then unit is set to targetUnit''',
    () {
      var configWrapper = SensorConfigWrapper(
        const SensorConfig(
          targetUnit: Temperature.kelvin,
          targetPrecision: 1,
          timeInterval: Duration(seconds: 1),
        ),
      );

      var sensorData = InternalSensorData(
        data: [
          1,
          2,
          3,
        ],
        maxPrecision: 5,
        unit: SensorUnit.celsius,
        timestampInMicroseconds: 0,
      );

      var preprocessedData = processData(sensorData, configWrapper);
      expect(preprocessedData.unit, equals(Temperature.kelvin));
    },
  );

  test(
      'When sensor data is preprocessed, then output data has precision of '
      'sensor config', () {
    var configWrapper = SensorConfigWrapper(
      const SensorConfig(
        targetUnit: Temperature.celsius,
        targetPrecision: 1,
        timeInterval: Duration(seconds: 1),
      ),
    );

    var sensorData = InternalSensorData(
      data: [
        1,
        2,
        3,
      ],
      maxPrecision: 2,
      unit: SensorUnit.celsius,
      timestampInMicroseconds: 0,
    );
    var preprocessedData = processData(sensorData, configWrapper);
    expect(
      preprocessedData.maxPrecision,
      configWrapper.sensorConfig.targetPrecision,
    );
  });
}
