import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

final Map<Angle, List<num>> angleConversions = {
  Angle.radians: [0, pi, 2 * pi, pi / 3],
  Angle.turns: [0, 0.5, 1, 1 / 6],
  Angle.gradian: [0, 200, 400, 200 / 3],
  Angle.degrees: [0, 180, 360, 60],
  Angle.arcminutes: [0, 10800, 21600, 3600],
  Angle.arcseconds: [0, 648000, 1296000, 216000],
};

void main() {
  group('Angle', () {
    expectCorrectConversions(
      conversionMap: angleConversions,
      units: Angle.values,
    );
  });
}
