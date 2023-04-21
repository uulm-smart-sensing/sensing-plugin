import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

void main() {
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
}
