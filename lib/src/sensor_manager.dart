import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show SensorManagerApi, SensorId, Unit;

/// Singleton sensor manager class
class SensorManager {
  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance
  factory SensorManager() => _singleton;

  SensorManager._internal();

  //Propose: i don't know if it is better if we cast this method with future
  Map<SensorId, EventChannel> _getsensorId(SensorId id) {
    //get the sensorid and returns a map with id and eventchannel
    var channel = EventChannel('sensors/[$id]');
    try {
      channel.receiveBroadcastStream();
      return {id: channel};
      //throws an exception if there is problem on the native side
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

// TODO: implement and document this method
//checks if the Sensor is currently used and returns an bool
  bool _isSensorUsed(SensorId id) => false;

//checks if the Sensor is available and returns the SensorID
  bool _isSensorAvailable(SensorId id) =>
      SensorManager()._isSensorAvailable(id);

// TODO: implement and document this method
  ///checks if the sensor is being edited and returns an bool
  bool startSensorTracking(
    SensorId id,
    Unit units,
    int precision,
    Duration interval,
  ) =>
      false;

// TODO: implement and document this method
  ///checks if the sensor is being edited and returns an bool
  bool editSensor(String id, String units, int precision, Duration interval) =>
      false;
}
