import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

final Map<MagneticFluxDensity, List<num>> magneticFluxDensityConversions = {
  MagneticFluxDensity.tesla: [0, 1, 0.0005, 0.000007],
  MagneticFluxDensity.gauss: [0, 10000, 5, 0.07],
  MagneticFluxDensity.microTesla: [0, 1000000, 500, 7],
};

void main() {
  group('Magnetic Flux Density', () {
    expectCorrectConversions(
      conversionMap: magneticFluxDensityConversions,
      units: MagneticFluxDensity.values,
    );
  });
}
