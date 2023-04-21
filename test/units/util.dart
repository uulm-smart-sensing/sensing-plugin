import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

const delta = 1E-8;

void expectCorrectConversion<T extends Unit<T>>({
  required T sourceUnit,
  required T targetUnit,
  required double sourceValue,
  required double expectedValue,
}) {
  var result = sourceUnit.convertTo(targetUnit, sourceValue);
  expect(result, closeTo(expectedValue, delta));
}
