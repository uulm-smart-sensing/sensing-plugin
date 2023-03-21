import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/extensions/sensor_data_extension.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';

void main() {
  test(
      'When copyWith is called without parameters, then copy has same '
      'properties', () {
    var sensorData = SensorData(
      data: [1, 2, 3],
      maxPrecision: 2,
      unit: Unit.unitless,
    );
    var copy = sensorData.copyWith();
    expect(copy.data, equals([1, 2, 3]));
    expect(copy.maxPrecision, equals(2));
    expect(copy.unit, equals(Unit.unitless));
  });

  test(
      'When copyWith is called with null parameters, then copy has same '
      'properties', () {
    var sensorData = SensorData(
      data: [1, 2, 3],
      maxPrecision: 2,
      unit: Unit.unitless,
    );
    var copy = sensorData.copyWith(data: null, maxPrecision: null, unit: null);
    expect(copy.data, equals([1, 2, 3]));
    expect(copy.maxPrecision, equals(2));
    expect(copy.unit, equals(Unit.unitless));
  });

  test(
      'When copyWith is called with different non null parameters, then copy '
      'has different properties', () {
    var sensorData = SensorData(
      data: [1, 2, 3],
      maxPrecision: 2,
      unit: Unit.unitless,
    );
    var copy = sensorData.copyWith(
      data: [4, 5, 6],
      maxPrecision: 3,
      unit: Unit.celsius,
    );
    expect(copy.data, equals([4, 5, 6]));
    expect(copy.maxPrecision, equals(3));
    expect(copy.unit, equals(Unit.celsius));
  });
}
