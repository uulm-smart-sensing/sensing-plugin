import 'package:sembast/timestamp.dart';

class SensorData{

  final double x;
  final double y;
  final double z;
  late final Timestamp time;

  SensorData(this.x, this.y, this.z){
   time = Timestamp.now();
  }
  @override
  String toString(){
    return "(X) = ${x.toStringAsFixed(2)} (Y) = ${y.toStringAsFixed(2)} (Z) = ${z.toStringAsFixed(2)} Timestamp: ${time.toIso8601String()}";
  }
}