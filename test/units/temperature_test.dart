import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/units/unit.dart';

import 'util.dart';

final Map<Temperature, List<num>> temperatureConversions = {
  Temperature.kelvin: [0, 273.15, 323.15, 373.15],
  Temperature.celsius: [-273.15, 0, 50, 100],
  Temperature.rankine: [0, 491.67, 581.67, 671.67],
  Temperature.fahrenheit: [-459.67, 32, 122, 212],
};

void main() {
  group('Temperature', () {
    expectCorrectConversions(
      conversionMap: temperatureConversions,
      units: Temperature.values,
    );
  });
}
