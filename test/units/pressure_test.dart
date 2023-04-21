import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

void main() {
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
}
