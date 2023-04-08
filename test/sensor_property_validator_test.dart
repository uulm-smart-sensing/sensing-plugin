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
      expect(validatePrecision(-1), isFalse);
    });

    test(
        'When the precision is above 10 , then validatePrecision returns false',
        () {
      expect(validatePrecision(100), isFalse);
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
      },
    );
  });

  group("Validiting units", () {
    test('''When the id & unit passes back accelerometer and
      metersPerSecondSquared then validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.accelerometer,
          Unit.metersPerSecondSquared,
        ),
        isTrue,
      );
    });
    test('''When the id & unit passes back accelerometer and gravitationalForce
      then validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.accelerometer,
          Unit.gravitationalForce,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back gyroscope and radiansPerSecond then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.gyroscope,
          Unit.radiansPerSecond,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back gyroscope and degreesPerSecond then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.gyroscope,
          Unit.degreesPerSecond,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back magnetometer and magnometer then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.magnetometer,
          Unit.microTeslas,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back orientation and radians then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.orientation,
          Unit.radians,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back orientation and degrees then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.orientation,
          Unit.degrees,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back linearAcceleration and
    metersPerSecondSquared then validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.linearAcceleration,
          Unit.metersPerSecondSquared,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back linearAcceleration and
      gravitationalForce then validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.linearAcceleration,
          Unit.gravitationalForce,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back barometer and hectoPascal then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.barometer,
          Unit.hectoPascal,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back barometer and kiloPascal then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.barometer,
          Unit.kiloPascal,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back barometer and bar then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.barometer,
          Unit.bar,
        ),
        isTrue,
      );
    });
    test('''When the id & unit passes back thermometer and kelvin then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.thermometer,
          Unit.kelvin,
        ),
        isTrue,
      );
    });

    test('''When the id & unit  passes back thermometer and fahrenheit then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.thermometer,
          Unit.fahrenheit,
        ),
        isTrue,
      );
    });

    test('''When the id & unit passes back thermometer and celsius then
        validateUnitCompatibility return true''', () {
      expect(
        validateUnitCompatibility(
          SensorId.thermometer,
          Unit.celsius,
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
