import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

// to check these values see: https://en.wikipedia.org/wiki/Metre_per_second_squared
// and https://simple.wikipedia.org/wiki/Foot_(unit)
final Map<Acceleration, List<num>> accelerationConversions = {
  Acceleration.gravity: [0, 10, 0.509858106488, 0.124323800686],
  Acceleration.gal: [0, 9806.65, 500, 121.92],
  Acceleration.meterPerSecondSquared: [0, 98.0665, 5, 1.2192],
  Acceleration.inchPerSecondSquared: [0, 3860.8858267716, 196.8503937007, 48],
  Acceleration.footPerSecondSquared: [0, 321.7404855643, 16.4041994750, 4],
};

void main() {
  group('Acceleration', () {
    expectCorrectConversions(
      conversionMap: accelerationConversions,
      units: Acceleration.values,
    );
  });
}
