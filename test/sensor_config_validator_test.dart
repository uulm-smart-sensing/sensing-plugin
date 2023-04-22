import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/sensor_config_validator.dart';

void main() {
  group(
    "Validiting precision",
    () {
      test(
        'When the precision is valid, then validatePrecision returns true',
        () {
          expect(validatePrecision(9), isTrue);
        },
      );

      test(
        'When the precision is negative, then validatePrecision returns false',
        () {
          expect(validatePrecision(-1), isFalse);
        },
      );

      test(
        'When the precision is above 10 , then validatePrecision returns false',
        () {
          expect(validatePrecision(100), isFalse);
        },
      );
    },
  );

  group(
    "Validiting timeInterval in milliseconds",
    () {
      test(
        'When the interval is valid then validateTimeInterval returns true',
        () {
          expect(validateIntervalInMilliseconds(15), isTrue);
        },
      );
      test(
        'When the interval is negative then validateTimeInterval returns false',
        () {
          expect(validateIntervalInMilliseconds(-1), isFalse);
        },
      );
      test(
        "When the interval is too large"
        "then validateTimeInterval returns false",
        () {
          expect(validateIntervalInMilliseconds(31536000001), isFalse);
        },
      );
    },
  );
}
