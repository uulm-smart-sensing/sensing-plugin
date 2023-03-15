import 'generated/api_sensor_manager.dart' show SensorId, Unit;

class Sensor {
  SensorId? _id;
  String? _name;
  Unit? _unit;
  int? _accuracy;
  Duration? _timeInterval;

  /// constructor
  Sensor(SensorId id, String name, Unit unit, int accuracy,
      Duration timeInterval) {
    _id = id;
    _name = name;
    _unit = unit;
    accuracy = accuracy;
    _timeInterval = timeInterval;
  }
}
