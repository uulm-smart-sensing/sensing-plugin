import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/units/unit.dart';

const delta = 1E-8;

final List<Unit> all_units = [
  ...Acceleration.values,
  ...Angle.values,
  ...AngularVelocity.values,
  ...MagneticFluxDensity.values,
  ...Pressure.values,
  ...Temperature.values,
];

void main() {
  test(
      'When same unit is used for source and target unit, then same value is '
      'returned', () {
    for (var unit in all_units) {
      var result = unit.convertTo(unit, 42);
      var name = unit.toTextDisplay(isShort: true);
      expect(
        result,
        closeTo(42, delta),
        reason: 'Result of converting 42 in $name to $name must be 42.',
      );
    }
  });

  test('When value is converted back and forth, then result is the same', () {
    for (var sourceUnit in all_units) {
      for (var targetUnit in all_units.where((unit) =>
          unit != sourceUnit && unit.runtimeType == sourceUnit.runtimeType)) {
        var source = sourceUnit.toTextDisplay(isShort: true);
        var target = targetUnit.toTextDisplay(isShort: true);
        var valueInTargetUnit = sourceUnit.convertTo(targetUnit, 42);
        var valueInSourceUnit = targetUnit.convertTo(
          sourceUnit,
          valueInTargetUnit,
        );
        expect(
          valueInSourceUnit,
          closeTo(42, delta),
          reason: 'Converting 42 from $source to $target and back must be 42.',
        );
      }
    }
  });

  // TODO: Add unit conversion tests for new units

  group('Acceleration', () {
    test('When value in m/s^2 is converted to Gs, then result is correct', () {
      var result = Acceleration.meterPerSecondSquared
          .convertTo(Acceleration.gravity, 23);
      expect(result, closeTo(2.345347289849, delta));
    });

    test('When value in Gs is converted to m/s^2, then result is correct', () {
      var result = Acceleration.gravity
          .convertTo(Acceleration.meterPerSecondSquared, 12);
      expect(result, closeTo(117.6798, delta));
    });
  });

  group('Angular Velocity', () {
    test(
      'When value in radians/s is converted to degrees/s, then result is '
      'correct',
      () {
        var result = AngularVelocity.radiansPerSecond
            .convertTo(AngularVelocity.degreesPerSecond, 16);
        expect(result, closeTo(916.7324722093, delta));
      },
    );

    test(
      'When value in degrees/s is converted to radians/s, then result is '
      'correct',
      () {
        var result = AngularVelocity.degreesPerSecond
            .convertTo(AngularVelocity.radiansPerSecond, 87);
        expect(result, closeTo(1.518436449235, delta));
      },
    );
  });

  group('Magnetic Flux Density', () {});

  group('Angle', () {
    test(
      'When value in radians is converted to degrees, then result is correct',
      () {
        var result = Angle.radians.convertTo(Angle.degrees, 5.34);
        expect(result, closeTo(305.9594625999, delta));
      },
    );

    test(
      'When value in degrees is converted to radians, then result is correct',
      () {
        var result = Angle.degrees.convertTo(Angle.radians, 69);
        expect(result, closeTo(1.204277183876, delta));
      },
    );
  });

  group('Pressure', () {
    test('When value in hPa is converted to bar, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.hectoPascal,
        targetUnit: Pressure.bar,
        sourceValue: 123456,
        expectedValue: 123.456,
      );
    });

    test('When value in bar is converted to hPa, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.bar,
        targetUnit: Pressure.hectoPascal,
        sourceValue: 11,
        expectedValue: 11000,
      );
    });

    test('When value in bar is converted to kPa, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.bar,
        targetUnit: Pressure.kiloPascal,
        sourceValue: 11,
        expectedValue: 1100,
      );
    });

    test('When value in kPa is converted to bar, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.kiloPascal,
        targetUnit: Pressure.bar,
        sourceValue: 123456,
        expectedValue: 1234.56,
      );
    });

    test('When value in hPa is converted to kPa, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.hectoPascal,
        targetUnit: Pressure.kiloPascal,
        sourceValue: 12,
        expectedValue: 1.2,
      );
    });

    test('When value in kPa is converted to hPa, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Pressure.kiloPascal,
        targetUnit: Pressure.hectoPascal,
        sourceValue: 1,
        expectedValue: 10,
      );
    });
  });

  group('Temperature', () {
    test('When value in °C is converted to °F, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.celsius,
        targetUnit: Temperature.fahrenheit,
        sourceValue: 31,
        expectedValue: 87.8,
      );
    });

    test('When value in °F is converted to °C, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.fahrenheit,
        targetUnit: Temperature.celsius,
        sourceValue: 123,
        expectedValue: 50.55555555533,
      );
    });

    test('When value in °C is converted to K, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.celsius,
        targetUnit: Temperature.kelvin,
        sourceValue: 66,
        expectedValue: 339.15,
      );
    });

    test('When value in K is converted to °C, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.kelvin,
        targetUnit: Temperature.celsius,
        sourceValue: 298,
        expectedValue: 24.85,
      );
    });

    test('When value in °F is converted to K, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.fahrenheit,
        targetUnit: Temperature.kelvin,
        sourceValue: 167,
        expectedValue: 348.1499999998,
      );
    });

    test('When value in K is converted to °F, then result is correct', () {
      expectCorrectConversion(
        sourceUnit: Temperature.kelvin,
        targetUnit: Temperature.fahrenheit,
        sourceValue: 265,
        expectedValue: 17.33,
      );
    });
  });
}

void expectCorrectConversion<T extends Unit<T>>({
  required T sourceUnit,
  required T targetUnit,
  required double sourceValue,
  required double expectedValue,
}) {
  var result = sourceUnit.convertTo(targetUnit, sourceValue);
  expect(result, closeTo(expectedValue, delta));
}
