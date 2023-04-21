import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

void main() {
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
