// ignore_for_file: prefer_final_fields

import 'package:flutter/services.dart';

import 'generated/api_sensor_manager.dart'
    show SensorManagerApi, SensorId, Unit;

/// Singleton sensor manager class

class SensorManager {
  List<SensorId> _usedSenors = [];
  List<SensorId> _allSensors = SensorId.values.toList();
  List<Stream> _sensorStreams = [];
  bool _sensorUse = false;
  bool _sensorTracking = false;
  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance
  factory SensorManager() => _singleton;

  SensorManager._internal();

  Future<Map<SensorId, EventChannel>> getSensorId(SensorId id) async {
    /// get the sensorid and returns a map with id and eventchannel
    var channel = EventChannel('sensors/[$id]');
    try {
      channel.receiveBroadcastStream();
      return {id: channel};
      //throws an exception if there is problem on the native side
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }

  /// TODO: implement and document this method
  void _initializeAllSensors() {}

  /// TODO: implement and document this method
  void _makeAvaibleSensorsUsable() {}

// TODO: implement and document this method
//checks if the Sensor is currently used and returns an bool
  bool _isSensorUsed(SensorId id) {
    _usedSenors.add(id);
    _sensorUse = true;
    return _sensorUse;
  }

//checks if the Sensor is available and returns the SensorID
  Future<bool> _isSensorAvailable(SensorId id) async =>
      SensorManagerApi().isSensorAvailable(id);


  Future<bool> startSensorTracking(
    SensorId id,
    Unit units,
    int precision,
    Duration interval,
  ) async {
    if (await _isSensorAvailable(id)) {
      _isSensorUsed(id);
      /// TODO: implementation to configuration of the sensor

      return _sensorTracking = true;
    } else {
      return _sensorTracking = false;
    }
  }

  bool stopSensorTracking(
    SensorId id,
    Unit units,
    int precision,
    Duration interval,
  ) {
    if (_sensorTracking) {
      _sensorUse = false;
      _sensorTracking = false;
      // TODO: implementation for updating sensor

      return true;
    }
    return true;
  }

  /// TODO: whole method needs to be adjusted
  bool editSensor(SensorId id, Unit units, int precision, Duration interval) =>
      true;

  ///
  List<SensorId> getUsedSensors() => _usedSenors;
  ///
  List<SensorId> getUsableSensors() =>
      _allSensors.toSet().difference(_usedSenors.toSet()).toList();

/*List<SensorId> getSensor (String name){
SensorId match;
  for(SensorId id in SensorId.values){
      if(id.t
  }
    if (_allSensors.contains(name)){

    }else{
      return [];
    }
  }*/
}
