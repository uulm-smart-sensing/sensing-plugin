import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

void main() {
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
}
