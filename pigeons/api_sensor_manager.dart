import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class SensorManagerApi {
  /// Checks whether the sensor with the passed [SensorId] is available.
  @async
  bool isSensorAvailable(SensorId id);

  /// Checks whether the sensor with the passed [SensorId] is currently used.
  ///
  /// 'used' means that tracking for this sensor was started in the past and has
  /// not yet been stopped.
  @async
  bool isSensorUsed(SensorId id);

  /// Starts tracking of the sensor with the passed [SensorId].
  ///
  /// The sensor sends data via the event channel every
  /// [timeIntervalInMilliseconds] ms.
  @async
  ResultWrapper startSensorTracking(
    SensorId id,
    int timeIntervalInMilliseconds,
  );

  /// Stops tracking of the sensor with the passed [SensorId].
  @async
  ResultWrapper stopSensorTracking(SensorId id);

  /// Changes the interval of the sensor event channel with the passed
  /// [SensorId] to [timeIntervalInMilliseconds] ms.
  @async
  ResultWrapper changeSensorTimeInterval(
    SensorId sensorId,
    int timeIntervalInMilliseconds,
  );

  /// Retrieves information about the sensor with the passed [SensorId].
  @async
  SensorInfo getSensorInfo(SensorId id);

  /// [SensorData] isn't used in any method but returned via the event channel.
  ///
  /// For the class to be generated on the platforms it must be referenced in at
  /// least one method.
  // ignore: unused_element
  void _dummyMethod(SensorData data);
}

enum SensorId {
  accelerometer,
  gyroscope,
  magnetometer,
  heading,
  linearAcceleration,
  barometer,
  thermometer,
}

/// The unit of the sensor output data
enum Unit {
  // Acceleration
  metersPerSecondSquared,
  gravitationalForce,
  // Angular velocity
  radiansPerSecond,
  degreesPerSecond,
  // Magnetic flux density
  microTeslas,
  // Angle
  radians,
  degrees,
  // Pressure
  hectoPascal,
  bar,
  // Temperature
  celsius,
  fahrenheit,
  kelvin,
  // Miscellaneous
  unitless,
}

/// Wrappes [SensorTaskResult] enum.
///
/// Enums aren't yet supported for primitive return types.
class ResultWrapper {
  const ResultWrapper(this.state);

  final SensorTaskResult state;
}

/// The result of a task executed by a sensor.
enum SensorTaskResult {
  /// The task was executed without an error.
  success,

  /// The sensor corresponding to the task was not available.
  sensorNotAvailable,

  /// The sensor corresponding to the task is already being tracked.
  alreadyTrackingSensor,

  // The sensor corresponding to the task was not being tracked.
  notTrackingSensor,

  // The sensor time interval corresponding to the task was invalid.
  invalidTimeInterval,

  /// The action was executed successfully, but there are some warnings
  /// (e.g. sensor updates not always possible, depending on the device)
  warning,

  /// The action couldn't be executed without an error.
  failure,
}

class SensorInfo {
  SensorInfo(
    this.unit,
    this.accuracy,
    this.timeIntervalInMilliseconds,
  );

  Unit unit;
  int accuracy;
  int timeIntervalInMilliseconds;
}

/// Raw sensor data with information about precision and unit.
class SensorData {
  SensorData(
    this.data,
    this.maxPrecision,
    this.unit,
  );

  List<double?> data;
  int maxPrecision;
  Unit unit;
}
