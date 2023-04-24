import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

final List<Unit> allUnits = [
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
    for (var unit in allUnits) {
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
    for (var sourceUnit in allUnits) {
      for (var targetUnit in allUnits.where(
        (unit) =>
            unit != sourceUnit && unit.runtimeType == sourceUnit.runtimeType,
      )) {
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
}
