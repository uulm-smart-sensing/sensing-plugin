import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart' show SensorManagerApi, SensorId, Unit;

/// Singleton sensor manager class
class SensorManager {
final EventChannel _eventChannel = EventChannel('pigeons\api_sensor_manager.dart');

  Map _id = <SensorId,EventChannel>{} ;
  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance
  factory SensorManager() => _singleton;

  SensorManager._internal(

      ///constructor code
      );

//checks if the Sensor is currently used and returns an bool
  bool _isSensorUsed(SensorId id) => false;

//checks if the Sensor is available and returns the sensor
  bool _isSensorAvailable(SensorId id) =>
      SensorManager()._isSensorAvailable(id);

  ///checks if the sensor is being edited and returns an bool
  bool startSensorTracking(
    SensorId id,
    Unit units,
    int precision,
    Duration interval,
  ) =>
      false;

  ///checks if the sensor is being edited and returns an bool
  bool editSensor(String id, String units, int precision, Duration interval) =>
      false;
}
