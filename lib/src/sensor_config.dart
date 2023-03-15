import 'generated/api_sensor_manager.dart' show SensorId, Unit;

class SensorConfig {
  SensorId? _id;
  Unit? _targetUnit;
  int? _currentPrecision;
  Duration? _timeInterval;

  /// constructor
  SensorConfig(SensorId id, Unit targetUnit, int currentPrecision,
      Duration timeInterval) {
    _id = id;
    _targetUnit = targetUnit;
    _currentPrecision = _currentPrecision;
    _timeInterval = timeInterval;
  }

  Unit? get targetUnit => this._targetUnit;
  set targetUnit(Unit? value) => this._targetUnit = value;

  int? get currentPrecision => this._currentPrecision;
  set currentPrecision(int? value) => this._currentPrecision = value;

  Duration? get timeInterval => this._timeInterval;
  set timeInterval(Duration? value) => this._timeInterval = value;
}
