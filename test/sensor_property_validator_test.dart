import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/src/sensor_property_validator.dart';

void main() {
  group("Validiting precision", () {
    test('When the numbers correspond to the norm', () {
      expect(SensorPropertyValidator().checkPrecision(9), isTrue);
    });

    test('When the numbers do not correspond to the norm', () {
      bool result;
      result = SensorPropertyValidator().checkPrecision(-1);
      expect(result, isFalse);

      result = SensorPropertyValidator().checkPrecision(100);
      expect(result, isFalse);
    });
  });

  group("Validiting timeInterval", () {
    test('When the numbers correspond to the norm', () {
      expect(SensorPropertyValidator().checkTimeInterval(9), isTrue);
    });

    test('When the numbers do not correspond to the norm', () {
      bool result;
      result = SensorPropertyValidator().checkTimeInterval(-1);
      expect(result, isFalse);

      result = SensorPropertyValidator().checkTimeInterval(31536000001);
      expect(result, isFalse);
    });
  });

  group("Validiting timeInterval", () {
    test('When the numbers correspond to the norm', () {
      expect(SensorPropertyValidator().checkTimeInterval(9), isTrue);
    });

    test('When the numbers do not correspond to the norm', () {
      bool result;
      result = SensorPropertyValidator().checkTimeInterval(-1);
      expect(result, isFalse);

      result = SensorPropertyValidator().checkTimeInterval(31536000001);
      expect(result, isFalse);
    });
  });

  test('When the id passes back the appropriate unit', () {
    expect(
      SensorPropertyValidator()
          .checkUnit(SensorId.accelerometer, Unit.metersPerSecondSquared),
      isTrue,
    );
  });
}
