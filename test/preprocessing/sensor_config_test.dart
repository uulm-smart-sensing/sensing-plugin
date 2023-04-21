import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/src/units/unit.dart';

void main() {
  test(
    'When sensor config is copied without parameters then object stays the '
    'same',
    () {
      var config = const SensorConfig(
        targetUnit: Temperature.celsius,
        targetPrecision: 2,
        timeInterval: Duration(milliseconds: 100),
      );

      var copy = config.copyWith();
      expect(copy.targetUnit, equals(config.targetUnit));
      expect(copy.targetPrecision, equals(config.targetPrecision));
      expect(copy.timeInterval, equals(config.timeInterval));
    },
  );

  test(
    'When sensor config is copied with parameters then values are overwritten',
    () {
      var config = const SensorConfig(
        targetUnit: Temperature.celsius,
        targetPrecision: 2,
        timeInterval: Duration(milliseconds: 100),
      );

      var copy = config.copyWith(
        targetUnit: Temperature.fahrenheit,
        targetPrecision: 3,
        timeInterval: const Duration(milliseconds: 300),
      );
      expect(copy.targetUnit, equals(Temperature.fahrenheit));
      expect(copy.targetPrecision, equals(3));
      expect(copy.timeInterval, equals(const Duration(milliseconds: 300)));
    },
  );
}
