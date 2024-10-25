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
  InternalSensorInfo getSensorInfo(SensorId id);

  /// [InternalSensorData] isn't used in any method but returned
  ///  via the event channel.
  ///
  /// For the class to be generated on the platforms it must be referenced in at
  /// least one method.
  // ignore: unused_element
  void _dummyMethod(InternalSensorData data);
}

enum SensorId {
  accelerometer,
  gyroscope,
  magnetometer,
  orientation,
  linearAcceleration,
  barometer,
  thermometer,
}

/// The unit of the sensor output data
enum SensorUnit {
  // Acceleration
  metersPerSecondSquared,
  gravitationalForce,
  // Angular velocity
  radiansPerSecond,
  // Magnetic flux density
  microTeslas,
  // Angle
  radians,
  degrees,
  // Pressure
  hectoPascal,
  kiloPascal,
  // Temperature
  celsius,
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

  /// The sensor corresponding to the task was not being tracked.
  notTrackingSensor,

  /// The sensor time interval corresponding to the task was invalid.
  invalidTimeInterval,

  /// The sensor precision corresponding to the task was invalid.
  invalidPrecision,

  /// The sensor unit corresponding to the task was invalid.
  invalidUnit,

  /// The action was executed successfully, but there are some warnings
  /// (e.g. sensor updates not always possible, depending on the device)
  warning,

  /// The action couldn't be executed without an error.
  failure,
}

/// Basic information about a sensor.
///
/// The sensor will report data with an [accuracy] in the specified
/// [timeIntervalInMilliseconds]. The values will be in the fixed [unit].
class InternalSensorInfo {
  InternalSensorInfo(
    this.unit,
    this.accuracy,
    this.timeIntervalInMilliseconds,
  );

  SensorUnit unit;
  SensorAccuracy accuracy;
  int timeIntervalInMilliseconds;
}

/// Sensor data with information about [maxPrecision], [unit] and the Unix
/// [timestampInMicroseconds] of when the data was measured.
class InternalSensorData {
  InternalSensorData(
    this.data,
    this.maxPrecision,
    this.unit,
    this.timestampInMicroseconds,
  );

  List<double?> data;
  int maxPrecision;
  SensorUnit unit;
  int timestampInMicroseconds;
}

/// Represents the accuracy with which the sensor reports data.
///
/// Note: Reporting the accuracy of a sensor has is a feature that only Android
/// has, so the [SensorAccuracy] on iOS devices will always be
/// [SensorAccuracy.high].
enum SensorAccuracy {
  /// The sensor is reporting data with maximum accuracy.
  high,

  /// The sensor is reporting data with an average level of accuracy,
  /// calibration with the environment may improve the readings.
  medium,

  /// The sensor is reporting data with low accuracy, calibration with the
  /// environment is needed.
  low,

  /// The values returned by the sensor cannot be trusted, calibration is
  /// needed or the environment doesn't allow readings.
  unreliable,

  /// The values returned by the sensor cannot be trusted because the sensor had
  /// no contact with what it was measuring (for example, the heart rate monitor
  /// is not in contact with the user).
  noContact,
}
