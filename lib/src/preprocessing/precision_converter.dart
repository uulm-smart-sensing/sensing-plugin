/// Converts [value] to the same value, but with a precision of
/// [targetPrecision].
///
/// The parameter [targetPrecision] must be greater than or equal to 0 or
/// otherwise an [ArgumentError] is thrown.
///
/// Example:
/// ```
/// convertPrecision(value: 1.2345, targetPrecision: 0);    // 1.0
/// convertPrecision(value: 1.2345, targetPrecision: 2);    // 1.23
/// convertPrecision(value: 3791.2345, targetPrecision: 1); // 3791.2
/// convertPrecision(value: 1E-9, targetPrecision: 6);      // 0.0
/// convertPrecision(value: 37E-6, targetPrecision: 12);    // 0.000037
/// convertPrecision(value: 1.23, targetPrecision: -1);     // throws RangeError
/// ```
double convertPrecision({
  required double value,
  required int targetPrecision,
}) {
  if (targetPrecision < 0) {
    throw ArgumentError.value(
      targetPrecision,
      "targetPrecision",
      "Invalid value: value must be greater than or equal to 0",
    );
  }
  var factor = 1;
  for (var i = 0; i < targetPrecision; i++) {
    factor *= 10;
  }
  return (value * factor).roundToDouble() / factor;
}
