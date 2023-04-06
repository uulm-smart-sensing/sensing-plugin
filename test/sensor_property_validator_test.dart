import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/src/sensor_property_validator.dart';

void main() {
  group("Validiting precision", () {
    test('When the precision is valid, then validatePrecision returns true',
        () {
      expect(validatePrecision(9), isTrue);
    });

    test('When the precision is negative, then validatePrecision returns false',
        () {
      bool result;
      result = validatePrecision(-1);
      expect(result, isFalse);

      result = validatePrecision(100);
      expect(result, isFalse);
    });
  });

  group("Validiting timeInterval in milliseconds", () {
    test('When the interval is valid then validateTimeInterval returns true',
        () {
      expect(validateIntervalInMilliseconds(15), isTrue);
    });
    test(
        'When the interval is negative then validateTimeInterval returns false',
        () {
      expect(validateIntervalInMilliseconds(-1), isFalse);
    });
    test(
        "When the interval is too large then validateTimeInterval returns false",
        () {
      expect(validateIntervalInMilliseconds(31536000001), isFalse);
    });
  });

  group("Validiting units", () {
    test('''When the id passes back accelerometer then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.accelerometer,
          Unit.metersPerSecondSquared,
        ),
        isTrue,
      );
    });
    test('''When the id passes back gyroscope then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.gyroscope,
          Unit.radiansPerSecond,
        ),
        isTrue,
      );
    });

    test('''When the id passes back magnetometer then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.magnetometer,
          Unit.microTeslas,
        ),
        isTrue,
      );
    });

    test('''When the id passes back orientation then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.orientation,
          Unit.radians,
        ),
        isTrue,
      );
    });

    test('''When the id passes back linearAcceleration then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.linearAcceleration,
          Unit.metersPerSecondSquared,
        ),
        isTrue,
      );
    });

    test('''When the id passes back barometer then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.barometer,
          Unit.hectoPascal,
        ),
        isTrue,
      );
    });

    test('''When the id passes back thermometer then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.thermometer,
          Unit.kelvin,
        ),
        isTrue,
      );
    });
  });

  test('''When the specified unit does not match the id
        then validateUnitCompatibility return false''', () {
    expect(
      validateUnitCompatibility(SensorId.barometer, Unit.microTeslas),
      isFalse,
    );
  });

  test('''When the given id does not correspond to the unit then
        validateUnitCompatibility return false''', () {
    expect(
      validateUnitCompatibility(SensorId.accelerometer, Unit.kelvin),
      isFalse,
    );
  });
  test('''When both id and unit are different and have nothing in common then
        validateUnitCompatibility return false''', () {
    expect(
      validateUnitCompatibility(SensorId.gyroscope, Unit.kiloPascal),
      isFalse,
    );
  });
}
