import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

// to check these values see: https://en.wikipedia.org/wiki/Bar_(unit)
final Map<Pressure, List<num>> pressureConversions = {
  Pressure.bar: [0, 10, 34.47378646583924, 1.01325],
  Pressure.kiloPascal: [0, 1000, 3447.378646583924, 101.325],
  Pressure.hectoPascal: [0, 10000, 34473.78646583924, 1013.25],
  Pressure.pascal: [0, 1000000, 3447378.646583924, 101325],
  Pressure.psi: [0, 145.03773773022, 500, 14.6959487755142],
  Pressure.torr: [0, 7500.616827041697, 25857.466285751612, 760],
  Pressure.atmosphere: [0, 9.869232667160128, 34.0229819549363346, 1],
};

void main() {
  group('Pressure', () {
    expectCorrectConversions(
      conversionMap: pressureConversions,
      units: Pressure.values,
    );
  });
}
