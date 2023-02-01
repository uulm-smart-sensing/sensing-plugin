import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class SensorManagerApi {
  @async

  /// Checks whether the sensor with the passed [SensorId] is available.
  bool isSensorAvailable(SensorId id);

  @async

  /// Checks whether the sensor with the passed [SensorId] is currently used.
  ///
  /// 'used' means that tracking for this sensor started in the passed and has
  /// not yet been stopped.
  bool isSensorUsed(SensorId id);

  @async

  /// Starts tracking of the sensor with the passed [SensorId].
  ///
  /// The [Unit] specifies the unit of the sensor output data, which is sent
  /// via the sensor event channel with every [timeIntervalInMilliseconds] ms.
  StateIndicator startSensorTracking(
    SensorId id,
    Unit unit,
    int timeIntervalInMilliseconds,
  );

  @async

  /// Stops tracking of the sensor with the passed [SensorId].
  StateIndicator stopSensorTracking(SensorId id);

  @async

  /// Changes the interval of the sensor event channel to
  /// [timeIntervalInMilliseconds] ms.
  StateIndicator changeSensorTimeInterval(int timeIntervalInMilliseconds);

  @async

  /// Retrieves information about the sensor with the passed [SensorId].
  SensorInfo getSensorInfo(SensorId id);
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

/// Stores state enum.
///
/// Enums aren't yet supported for primitive return types.
class StateIndicator {
  StateIndicator(this.state);

  final State state;
}

enum State {
  success,
  fail,
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
