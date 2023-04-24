import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

final Map<AngularVelocity, List<num>> angularVelocityConversions = {
  AngularVelocity.radiansPerSecond: [0, 2 * pi, 2 * pi / 60],
  AngularVelocity.degreesPerSecond: [0, 360, 360 / 60],
  AngularVelocity.degreesPerMinute: [0, 360 * 60, 360],
  AngularVelocity.degreesPerHour: [0, 360 * 60 * 60, 360 * 60],
  AngularVelocity.revolutionPerMinute: [0, 60, 1],
  AngularVelocity.revolutionPerHour: [0, 3600, 60],
};

void main() {
  group('Angular Velocity', () {
    expectCorrectConversions(
      conversionMap: angularVelocityConversions,
      units: AngularVelocity.values,
    );
  });
}
