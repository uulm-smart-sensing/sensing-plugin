import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart';

/// Singleton sensor manager class
class SensorManager {
  static final SensorManager _singleton = SensorManager._internal();

  static late SensorManagerApi _api = SensorManagerApi();

  /// Get Sensor Manager singleton instance
  factory SensorManager() => _singleton;

  SensorManager._internal();

  Future<bool> isSensorAvailable() async {
    bool isGyroAvailable = await _api.isSensorAvailable(SensorId.heading);
    return isGyroAvailable;
  }

  Future<Stream<SensorData>> startTracking() async {
    ResultWrapper status =
        await _api.startSensorTracking(SensorId.heading, 1000);
    if (status.state == SensorTaskResult.success) {
      const EventChannel eventChannel = EventChannel('sensors/heading');
      Stream<SensorData> sensorStream =
          eventChannel.receiveBroadcastStream().map((event) {
        return SensorData(
            data: [event[0][0] as double, 0, 0],
            maxPrecision: event[1] as int,
            unit: Unit.unitless);
      });
      return sensorStream;
    }
    return Stream.empty();
  }
}
