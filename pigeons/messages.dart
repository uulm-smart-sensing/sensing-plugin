import 'package:pigeon/pigeon.dart';

class AxisData {
  double? xAxis;
  double? yAxis;
  double? zAxis;
}

@HostApi()
abstract class Api2Host {
  @async
  bool isSensorAvailable(int sensorId);

  @async
  bool updateSensorInterval(int sensorId, int newInterval);

  @async
  bool startEventChannel(int sensorId, int interval);
}
