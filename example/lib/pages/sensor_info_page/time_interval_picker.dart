import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class TimeIntervalPicker extends CommonPickerModel {
  String digits(int value, int length) => '$value'.padLeft(length, "0");

  TimeIntervalPicker({required DateTime startTime, super.locale}) {
    currentTime = startTime;
    setLeftIndex(currentTime.minute);
    setMiddleIndex(currentTime.second);
    setRightIndex(currentTime.millisecond);
  }

  /// Minutes
  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  /// Seconds
  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  /// Milliseconds
  @override
  String? rightStringAtIndex(int index) {
    // Configuring the available options is weird
    // Step sizes don't seem to be supported
    if (index >= 10 && index < 1000) {
      return digits(index, 4);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() => ":";

  @override
  String rightDivider() => ":";

  @override
  List<int> layoutProportions() => [1, 1, 2];

  @override
  DateTime finalTime() => currentTime.isUtc
      ? DateTime.utc(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          0, // hours
          currentLeftIndex(), // minutes
          currentMiddleIndex(), // seconds
          currentRightIndex(), // milliseconds
          0, // microseconds
        )
      : DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          0, // hours
          currentLeftIndex(), // minutes
          currentMiddleIndex(), // seconds
          currentRightIndex(), // milliseconds
          0, // microseconds
        );
}
