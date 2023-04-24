import 'package:flutter_test/flutter_test.dart';

import 'package:sensing_plugin/src/generated/api_sensor_manager.dart';
import 'package:sensing_plugin/src/sensor_info.dart';
import 'package:sensing_plugin/src/units/unit.dart';

void main() {
  group("SensorInfo", () {
    test("from InternalSensorInfo", () {
      var internal = InternalSensorInfo(
        unit: SensorUnit.gravitationalForce,
        accuracy: SensorAccuracy.high,
        timeIntervalInMilliseconds: 100,
      );

      var info = sensorInfoFromInternal(internal);

      expect(info.unit, Acceleration.gravity);
      expect(info.accuracy, internal.accuracy);
      expect(
        info.timeIntervalInMilliseconds,
        internal.timeIntervalInMilliseconds,
      );
    });
  });
}
