import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/sensor_config_validator.dart';
import 'package:sensing_plugin/src/units/unit.dart';

void main() {
  group(
    "Validating precision",
    () {
      test(
        'When the precision is valid, then validatePrecision returns true',
        () {
          expect(validatePrecision(9), isTrue);
        },
      );

      test(
        'When the precision is negative, then validatePrecision returns false',
        () {
          expect(validatePrecision(-1), isFalse);
        },
      );

      test(
        'When the precision is above 10 , then validatePrecision returns false',
        () {
          expect(validatePrecision(100), isFalse);
        },
      );
    },
  );

  group(
    "Validating timeInterval in milliseconds",
    () {
      test(
        'When the interval is valid then validateTimeInterval returns true',
        () {
          expect(validateInterval(15), isTrue);
        },
      );
      test(
        'When the interval is negative then validateTimeInterval returns false',
        () {
          expect(validateInterval(-1), isFalse);
        },
      );
      test(
        "When the interval is too large"
        "then validateTimeInterval returns false",
        () {
          expect(validateInterval(31536000001), isFalse);
        },
      );
    },
  );

  group("Validating unit category", () {
    var idToUnitMap = <SensorId, Unit>{
      SensorId.accelerometer: Acceleration.gal,
      SensorId.linearAcceleration: Acceleration.gravity,
      SensorId.gyroscope: AngularVelocity.radiansPerSecond,
      SensorId.magnetometer: MagneticFluxDensity.gauss,
      SensorId.orientation: Angle.gradian,
      SensorId.barometer: Pressure.bar,
      SensorId.thermometer: Temperature.rankine,
    };

    test(
      'gets checked for every SensorId',
      () {
        expect(
          idToUnitMap.length,
          SensorId.values.length,
        );
      },
    );

    for (var element in idToUnitMap.entries) {
      test(
        '''for ${element.key}''',
        () {
          expect(
            validateUnit(unit: element.value, sensorId: element.key),
            isTrue,
            reason:
                '''${element.value.runtimeType} should be the valid Unit category for ${element.key}''',
          );
        },
      );
    }
  });
}
