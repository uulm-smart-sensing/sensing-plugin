import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/src/preprocessing/precision_converter.dart';

const delta = 1E-10;

void main() {
  group('Number around 0', () {
    test(
      'When target precision is less than source precision, then decimal places'
      ' are truncated',
      () {
        var result = convertPrecision(value: 1.23456789, targetPrecision: 2);
        expect(result, closeTo(1.23, delta));
      },
    );

    test(
      'When source precision is less than target precision, then decimal places'
      ' remain the same',
      () {
        var result = convertPrecision(value: 1.234, targetPrecision: 12);
        expect(result, closeTo(1.234, delta));
      },
    );

    test(
      'When source precision is equal to the target precision, then decimal '
      'places remain the same',
      () {
        var result = convertPrecision(value: 1.23456789, targetPrecision: 8);
        expect(result, closeTo(1.23456789, delta));
      },
    );
  });

  group('Big number', () {
    test(
      'When target precision is less than source precision, then decimal places'
      ' are truncated',
      () {
        var result = convertPrecision(
          value: 123456789123456789.123456789,
          targetPrecision: 2,
        );
        expect(result, closeTo(123456789123456789.12, delta));
      },
    );

    test(
      'When source precision is less than target precision, then decimal places'
      ' remain the same',
      () {
        var result = convertPrecision(
          value: 123456789123456789.123,
          targetPrecision: 12,
        );
        expect(result, closeTo(123456789123456789.123, delta));
      },
    );

    test(
      'When source precision is equal to the target precision, then decimal '
      'places remain the same',
      () {
        var result = convertPrecision(
          value: 123456789123456789.123456789,
          targetPrecision: 9,
        );
        expect(result, closeTo(123456789123456789.123456789, delta));
      },
    );
  });

  group('Small number', () {
    test(
      'When target precision is less than source precision, then decimal places'
      ' are truncated',
      () {
        var result = convertPrecision(
          value: 1.23456789E-15,
          targetPrecision: 2,
        );
        expect(result, closeTo(0, delta));
      },
    );

    test(
      'When source precision is less than target precision, then decimal places'
      ' remain the same',
      () {
        var result = convertPrecision(value: 1.234E-13, targetPrecision: 18);
        expect(result, closeTo(1.234E-13, delta));
      },
    );

    test(
      'When source precision is equal to the target precision, then decimal '
      'places remain the same',
      () {
        var result = convertPrecision(
          value: 1.23456789E-10,
          targetPrecision: 18,
        );
        expect(result, closeTo(1.23456789E-10, delta));
      },
    );
  });

  group('Negative number', () {
    test(
      'When target precision is less than source precision, then decimal places'
      ' are truncated',
      () {
        var result = convertPrecision(value: -1.23456789, targetPrecision: 2);
        expect(result, closeTo(-1.23, delta));
      },
    );

    test(
      'When source precision is less than target precision, then decimal places'
      ' remain the same',
      () {
        var result = convertPrecision(value: -1.234, targetPrecision: 12);
        expect(result, closeTo(-1.234, delta));
      },
    );

    test(
      'When source precision is equal to the target precision, then decimal '
      'places remain the same',
      () {
        var result = convertPrecision(value: -1.23456789, targetPrecision: 8);
        expect(result, closeTo(-1.23456789, delta));
      },
    );
  });
}
