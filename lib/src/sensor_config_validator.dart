/// Variable for validating minPrecision
const configValidatorMinPrecision = 0;

/// Variable for validating maxPrecision
const configValidatorMaxPrecision = 10;

/// Checks whether the passed [precision] is valid. It is valid if it is
/// between [configValidatorMinPrecision] and [configValidatorMaxPrecision].
bool validatePrecision(int precision) =>
    precision >= configValidatorMinPrecision &&
    precision <= configValidatorMaxPrecision;

/// Variable for validating TimeInterval
/// one week, 23 hours, 59 minutes and 59 seconds is equivalent to
/// [maxTimeInterval]
const maxTimeInterval = 691199000;

/// Checks whether the passed [interval] is valid.It is valid if the interval
/// is between 10 and one week, 23 hours, 59 minutes and 59 seconds.The
/// minimum was not 0 because a sensor can hardly have such high frequencies.
///
bool validateIntervalInMilliseconds(int interval) =>
    interval >= 10 && interval <= maxTimeInterval;
