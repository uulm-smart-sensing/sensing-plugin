import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

void main() {
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
}
