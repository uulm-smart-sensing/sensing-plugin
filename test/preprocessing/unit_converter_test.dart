import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/src/preprocessing/unit_converter.dart';

const delta = 1E-8;

void main() {
  test('There should be a conversion method for each declared unit', () {
    for (var unit in Unit.values) {
      if (!unitConversionMethods.containsKey(unit)) {
        fail("There's no conversion method registered for $unit");
      }
    }
  });

  test(
      'When same unit is used for source and target unit, then same value is '
      'returned', () {
    for (var unit in Unit.values) {
      var result = convertUnit(value: 42, sourceUnit: unit, targetUnit: unit);
      expect(
        result,
        equals(42),
        reason: 'Result of converting 42 in $unit to $unit must be 42.',
      );
    }
  });

  group('Acceleration', () {
    var units = [
      Unit.metersPerSecondSquared,
      Unit.gravitationalForce,
    ];

    test(
      'When non-acceleration unit is target unit, then an exception is thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });

    test('When value in m/s^2 is converted to Gs, then result is correct', () {
      var result = convertUnit(
        value: 23,
        sourceUnit: Unit.metersPerSecondSquared,
        targetUnit: Unit.gravitationalForce,
      );
      expect(result, closeTo(2.345347289849, delta));
    });

    test('When value in Gs is converted to m/s^2, then result is correct', () {
      var result = convertUnit(
        value: 12,
        sourceUnit: Unit.gravitationalForce,
        targetUnit: Unit.metersPerSecondSquared,
      );
      expect(result, closeTo(117.6798, delta));
    });
  });

  group('Angular Velocity', () {
    var units = [
      Unit.radiansPerSecond,
      Unit.degreesPerSecond,
    ];

    test(
      'When non-angular velocity unit is target unit, then an exception is '
      'thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });

    test(
      'When value in radians/s is converted to degrees/s, then result is '
      'correct',
      () {
        var result = convertUnit(
          value: 16,
          sourceUnit: Unit.radiansPerSecond,
          targetUnit: Unit.degreesPerSecond,
        );
        expect(result, closeTo(916.7324722093, delta));
      },
    );

    test(
      'When value in degrees/s is converted to radians/s, then result is '
      'correct',
      () {
        var result = convertUnit(
          value: 87,
          sourceUnit: Unit.degreesPerSecond,
          targetUnit: Unit.radiansPerSecond,
        );
        expect(result, closeTo(1.518436449235, delta));
      },
    );
  });

  group('Magnetic Flux Density', () {
    var units = [
      Unit.microTeslas,
    ];

    test(
      'When non-magnetic flux density unit is target unit, then an exception is'
      ' thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });
  });

  group('Angle', () {
    var units = [
      Unit.radians,
      Unit.degrees,
    ];

    test('When non-angle unit is target unit, then an exception is thrown', () {
      expectExceptionWhenTargetUnitIsNotSupported(units);
    });

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });

    test(
      'When value in radians is converted to degrees, then result is correct',
      () {
        var result = convertUnit(
          value: 5.34,
          sourceUnit: Unit.radians,
          targetUnit: Unit.degrees,
        );
        expect(result, closeTo(305.9594625999, delta));
      },
    );

    test(
      'When value in degrees is converted to radians, then result is correct',
      () {
        var result = convertUnit(
          value: 69,
          sourceUnit: Unit.degrees,
          targetUnit: Unit.radians,
        );
        expect(result, closeTo(1.204277183876, delta));
      },
    );
  });

  group('Pressure', () {
    var units = [
      Unit.hectoPascal,
      Unit.kiloPascal,
      Unit.bar,
    ];

    test(
      'When non-pressure unit is target unit, then an exception is thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });

    test('When value in hPa is converted to bar, then result is correct', () {
      var result = convertUnit(
        value: 123456,
        sourceUnit: Unit.hectoPascal,
        targetUnit: Unit.bar,
      );
      expect(result, closeTo(123.456, delta));
    });

    test('When value in bar is converted to hPa, then result is correct', () {
      var result = convertUnit(
        value: 11,
        sourceUnit: Unit.bar,
        targetUnit: Unit.hectoPascal,
      );
      expect(result, closeTo(11000, delta));
    });

    test('When value in bar is converted to kPa, then result is correct', () {
      var result = convertUnit(
        value: 11,
        sourceUnit: Unit.bar,
        targetUnit: Unit.kiloPascal,
      );
      expect(result, closeTo(1100, delta));
    });

    test('When value in kPa is converted to bar, then result is correct', () {
      var result = convertUnit(
        value: 123456,
        sourceUnit: Unit.kiloPascal,
        targetUnit: Unit.bar,
      );
      expect(result, closeTo(1234.56, delta));
    });

    test('When value in hPa is converted to kPa, then result is correct', () {
      var result = convertUnit(
        value: 12,
        sourceUnit: Unit.hectoPascal,
        targetUnit: Unit.kiloPascal,
      );
      expect(result, closeTo(1.2, delta));
    });

    test('When value in kPa is converted to hPa, then result is correct', () {
      var result = convertUnit(
        value: 1,
        sourceUnit: Unit.kiloPascal,
        targetUnit: Unit.hectoPascal,
      );
      expect(result, closeTo(10, delta));
    });
  });

  group('Temperature', () {
    var units = [
      Unit.celsius,
      Unit.fahrenheit,
      Unit.kelvin,
    ];

    test(
      'When non-temperature unit is target unit, then an exception is thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });

    test('When value in °C is converted to °F, then result is correct', () {
      var result = convertUnit(
        value: 31,
        sourceUnit: Unit.celsius,
        targetUnit: Unit.fahrenheit,
      );
      expect(result, closeTo(87.8, delta));
    });

    test('When value in °F is converted to °C, then result is correct', () {
      var result = convertUnit(
        value: 123,
        sourceUnit: Unit.fahrenheit,
        targetUnit: Unit.celsius,
      );
      expect(result, closeTo(50.55555555533, delta));
    });

    test('When value in °C is converted to K, then result is correct', () {
      var result = convertUnit(
        value: 66,
        sourceUnit: Unit.celsius,
        targetUnit: Unit.kelvin,
      );
      expect(result, closeTo(339.15, delta));
    });

    test('When value in K is converted to °C, then result is correct', () {
      var result = convertUnit(
        value: 298,
        sourceUnit: Unit.kelvin,
        targetUnit: Unit.celsius,
      );
      expect(result, closeTo(24.85, delta));
    });

    test('When value in °F is converted to K, then result is correct', () {
      var result = convertUnit(
        value: 167,
        sourceUnit: Unit.fahrenheit,
        targetUnit: Unit.kelvin,
      );
      expect(result, closeTo(348.1499999998, delta));
    });

    test('When value in K is converted to °F, then result is correct', () {
      var result = convertUnit(
        value: 265,
        sourceUnit: Unit.kelvin,
        targetUnit: Unit.fahrenheit,
      );
      expect(result, closeTo(17.33, delta));
    });
  });

  group('Miscellaneous', () {
    var units = [
      Unit.unitless,
    ];

    test(
      'When non-miscellaneous unit is target unit, then an exception is thrown',
      () {
        expectExceptionWhenTargetUnitIsNotSupported(units);
      },
    );

    test('When value is converted back and forth, then result is the same', () {
      expectSameValueWhenConvertingBackAndForth(units);
    });
  });
}

void expectExceptionWhenTargetUnitIsNotSupported(
  List<Unit> supportedUnits,
) {
  var unsupportedUnits =
      Unit.values.where((element) => !supportedUnits.contains(element));
  for (var unit in unsupportedUnits) {
    expect(
      () => convertUnit(
        value: 0,
        sourceUnit: supportedUnits.first,
        targetUnit: unit,
      ),
      throwsA(isA<UnsupportedUnitException>()),
    );
  }
}

void expectSameValueWhenConvertingBackAndForth(List<Unit> units) {
  for (var sourceUnit in units) {
    for (var targetUnit in units.where((unit) => unit != sourceUnit)) {
      var valueInTargetUnit = convertUnit(
        value: 42,
        sourceUnit: sourceUnit,
        targetUnit: targetUnit,
      );
      var valueInSourceUnit = convertUnit(
        value: valueInTargetUnit,
        sourceUnit: targetUnit,
        targetUnit: sourceUnit,
      );
      expect(valueInSourceUnit, closeTo(42, delta));
    }
  }
}
