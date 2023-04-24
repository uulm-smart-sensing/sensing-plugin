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
  expect(
    result,
    closeTo(expectedValue, delta),
    reason:
        '''Expected conversion of $sourceValue ${sourceUnit.toTextDisplay(isShort: true)} to ${targetUnit.toTextDisplay(isShort: true)} to be $expectedValue, but was $result.''',
  );
}

void expectCorrectConversions<T extends Unit<T>>({
  required Map<T, List<num>> conversionMap,
  required List<T> units,
}) {
  test("number of conversions must match number of units", () {
    expect(conversionMap.keys.length, units.length);
  });

  conversionMap.forEach((sourceUnit, sourceValues) {
    conversionMap.forEach((targetUnit, expectedValues) {
      var testName =
          '''conversion from ${sourceUnit.toTextDisplay(isShort: true)} to ${targetUnit.toTextDisplay(isShort: true)}''';
      test(testName, () {
        for (var sourceValue in sourceValues) {
          var expectedValue = expectedValues[sourceValues.indexOf(sourceValue)];
          expectCorrectConversion(
            sourceUnit: sourceUnit,
            targetUnit: targetUnit,
            sourceValue: sourceValue.toDouble(),
            expectedValue: expectedValue.toDouble(),
          );
        }
      });
    });
  });
}
