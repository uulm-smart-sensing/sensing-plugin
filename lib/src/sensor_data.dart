// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'generated/api_sensor_manager.dart' show SensorId, Unit;

class SensorData {

List <double>? _data;
int? _maxPrecision;
Unit? _units;
SensorId? _sensor;


SensorData(List<double> data,int maxPrecision, Unit units, SensorId sensor ){
  _data = data;
  _maxPrecision = maxPrecision;
  _units = units;
  _sensor =sensor;
}

}
