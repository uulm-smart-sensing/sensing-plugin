// import 'generated/api_sensor_manager.dart' show SensorManagerApi, SensorId;

/// Singleton sensor manager class
class SensorManager {
  static final SensorManager _singleton = SensorManager._internal();

  /// Get Sensor Manager singleton instance
  factory SensorManager() => _singleton;

  SensorManager._internal();
}
