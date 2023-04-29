import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/src/sensor_manager/sensor_manager_api_pigeon.dart';
import 'package:sensing_plugin/src/sensor_manager/sensor_manager_api_platform.dart';

import 'platform_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var sensorManager = SensorManager();

  var initialPlatform = SensorManagerApiPlatform.instance;

  test('$SensorManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<SensorManagerPigeonApi>());
  });

  test("Sensor manager implements singleton pattern", () {
    var sensorManager = SensorManager();
    var sensorManager2 = SensorManager();

    expect(sensorManager, isNotNull);
    expect(sensorManager2, isNotNull);
    expect(identical(sensorManager, sensorManager2), isTrue);
  });

  setUp(
    () {
      var fakePlatform = MockSensorManagerApi();
      SensorManagerApiPlatform.instance = fakePlatform;
    },
  );

  tearDown(() async {
    for (var id in SensorId.values) {
      await sensorManager.stopSensorTracking(id);
    }
  });

  group("Correct implementation of the API methods", () {
    test(
      "Test `isSensorAvailable`",
      () async {
        expect(
          await sensorManager.isSensorAvailable(SensorId.accelerometer),
          isTrue,
        );

        expect(
          await sensorManager.isSensorAvailable(SensorId.thermometer),
          isFalse,
        );

        expect(
          await sensorManager.getUsableSensors().then((list) => list.length),
          5,
        );
      },
    );

    test(
      "Test `isSensorUsed`",
      () async {
        await sensorManager.startSensorTracking(
          id: SensorId.accelerometer,
          config: const SensorConfig(
            targetUnit: Acceleration.gravity,
            targetPrecision: 4,
            timeInterval: Duration(milliseconds: 10),
          ),
        );

        expect(
          await sensorManager.isSensorUsed(SensorId.accelerometer),
          isTrue,
        );

        expect(
          await sensorManager.isSensorUsed(SensorId.thermometer),
          isFalse,
        );
      },
    );

    test(
      """
Test `changeSensorTimeInterval` (not working if time interval is invalid or sensor not tracked)""",
      () async {
        expect(
          await sensorManager.changeSensorTimeInterval(
            id: SensorId.accelerometer,
            timeIntervalInMilliseconds: 700000000,
          ),
          SensorTaskResult.invalidTimeInterval,
        );

        expect(
          await sensorManager.changeSensorTimeInterval(
            id: SensorId.accelerometer,
            timeIntervalInMilliseconds: 100,
          ),
          SensorTaskResult.notTrackingSensor,
        );
      },
    );

    test("Test `changeSensorTimeInterval` (works if sensor is tracked)",
        () async {
      await sensorManager.startSensorTracking(
        id: SensorId.accelerometer,
        config: const SensorConfig(
          targetUnit: Acceleration.gravity,
          targetPrecision: 4,
          timeInterval: Duration(milliseconds: 50),
        ),
      );

      expect(
        await sensorManager.changeSensorTimeInterval(
          id: SensorId.accelerometer,
          timeIntervalInMilliseconds: 100,
        ),
        SensorTaskResult.success,
      );

      expect(
        sensorManager
            .getSensorConfig(SensorId.accelerometer)!
            .timeInterval
            .inMilliseconds,
        100,
      );

      expect(
        sensorManager.getSensorConfig(SensorId.accelerometer)!.targetPrecision,
        4,
      );
    });

    test(
      "Test `getSensorInfo`",
      () async {
        expect(
          await sensorManager
              .getSensorInfo(
                SensorId.accelerometer,
              )
              .then(
                (info) =>
                    info.accuracy == SensorAccuracy.high &&
                    info.unit == Acceleration.meterPerSecondSquared,
              ),
          isTrue,
        );

        expect(
          await sensorManager
              .getSensorInfo(
                SensorId.thermometer,
              )
              .then(
                (info) =>
                    info.accuracy == SensorAccuracy.medium &&
                    info.unit == Temperature.celsius,
              ),
          isTrue,
        );
      },
    );

    test(
        "Test `startSensorTracking` fails, if sensor is already tracked, "
        "not available or the config has problems", () async {
      const exampleConfig = SensorConfig(
        targetUnit: Acceleration.meterPerSecondSquared,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 100),
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.accelerometer,
          config: exampleConfig,
        ),
        SensorTaskResult.success,
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.accelerometer,
          config: exampleConfig,
        ),
        SensorTaskResult.alreadyTrackingSensor,
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.thermometer,
          config: const SensorConfig(
            targetUnit: Temperature.celsius,
            targetPrecision: 5,
            timeInterval: Duration(milliseconds: 100),
          ),
        ),
        SensorTaskResult.sensorNotAvailable,
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.gyroscope,
          config: const SensorConfig(
            targetUnit: AngularVelocity.radiansPerSecond,
            targetPrecision: 11,
            timeInterval: Duration(milliseconds: 100),
          ),
        ),
        SensorTaskResult.invalidPrecision,
      );
      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.gyroscope,
          config: const SensorConfig(
            targetUnit: AngularVelocity.radiansPerSecond,
            targetPrecision: 0,
            timeInterval: Duration(milliseconds: -1),
          ),
        ),
        SensorTaskResult.invalidTimeInterval,
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.gyroscope,
          config: const SensorConfig(
            targetUnit: Temperature.celsius,
            targetPrecision: 0,
            timeInterval: Duration(milliseconds: 100),
          ),
        ),
        SensorTaskResult.invalidUnit,
      );
      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.gyroscope,
          config: const SensorConfig(
            targetUnit: AngularVelocity.radiansPerSecond,
            targetPrecision: 0,
            timeInterval: Duration(milliseconds: 10),
          ),
        ),
        SensorTaskResult.warning,
      );
    });

    test("Test `startSensorTracking` is successful, if all conditions are met.",
        () async {
      const exampleConfig = SensorConfig(
        targetUnit: AngularVelocity.radiansPerSecond,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 200),
      );

      expect(
        await sensorManager.startSensorTracking(
          id: SensorId.gyroscope,
          config: exampleConfig,
        ),
        SensorTaskResult.success,
      );

      expect(
        sensorManager.getUsedSensors().contains(SensorId.gyroscope),
        isTrue,
      );

      expect(
        sensorManager
            .getSensorConfig(SensorId.gyroscope)!
            .timeInterval
            .inMilliseconds,
        200,
      );

      expect(
        sensorManager.getUsedSensors().contains(SensorId.accelerometer),
        isFalse,
      );

      expect(
        await sensorManager
            .getUsableSensors()
            .then((list) => list.contains(SensorId.gyroscope)),
        isFalse,
      );
    });

    test(
        "Test `stopSensorTracking` fails, if sensor not tracked / have problems.",
        () async {
      const exampleConfig = SensorConfig(
        targetUnit: AngularVelocity.radiansPerSecond,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 200),
      );

      await sensorManager.startSensorTracking(
        id: SensorId.gyroscope,
        config: exampleConfig,
      );

      expect(
        await sensorManager.stopSensorTracking(SensorId.thermometer),
        SensorTaskResult.notTrackingSensor,
      );
    });

    test("Test `stopSensorTracking` is successful, if all conditions are met.",
        () async {
      const exampleConfig = SensorConfig(
        targetUnit: AngularVelocity.radiansPerSecond,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 200),
      );

      await sensorManager.startSensorTracking(
        id: SensorId.gyroscope,
        config: exampleConfig,
      );

      expect(
        await sensorManager.stopSensorTracking(SensorId.gyroscope),
        SensorTaskResult.success,
      );

      expect(
        sensorManager.getUsedSensors().contains(SensorId.gyroscope),
        isFalse,
      );

      expect(sensorManager.getSensorConfig(SensorId.gyroscope), isNull);
    });

    test("Test `editSensorConfig` fails if config is not valid.", () async {
      const exampleConfig = SensorConfig(
        targetUnit: AngularVelocity.radiansPerSecond,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 200),
      );

      await sensorManager.startSensorTracking(
        id: SensorId.gyroscope,
        config: exampleConfig,
      );

      expect(
        await sensorManager.editSensorConfig(
          SensorId.gyroscope,
          targetUnit: Temperature.fahrenheit,
        ),
        SensorTaskResult.invalidUnit,
      );

      expect(
        await sensorManager.editSensorConfig(
          SensorId.gyroscope,
          targetPrecision: -1,
        ),
        SensorTaskResult.invalidPrecision,
      );

      expect(
        await sensorManager.editSensorConfig(
          SensorId.gyroscope,
          timeInterval: const Duration(seconds: -1),
        ),
        SensorTaskResult.invalidTimeInterval,
      );
    });

    test("Test `editSensorConfig`.", () async {
      const exampleConfig = SensorConfig(
        targetUnit: AngularVelocity.radiansPerSecond,
        targetPrecision: 5,
        timeInterval: Duration(milliseconds: 200),
      );

      expect(
        await sensorManager.editSensorConfig(SensorId.gyroscope),
        SensorTaskResult.notTrackingSensor,
      );

      await sensorManager.startSensorTracking(
        id: SensorId.gyroscope,
        config: exampleConfig,
      );

      expect(
        await sensorManager.editSensorConfig(SensorId.gyroscope),
        SensorTaskResult.success,
      );

      expect(
        await sensorManager.editSensorConfig(
          SensorId.gyroscope,
          targetUnit: AngularVelocity.revolutionPerHour,
        ),
        SensorTaskResult.success,
      );

      expect(
        sensorManager
                .getSensorConfig(
                  SensorId.gyroscope,
                )!
                .targetUnit ==
            AngularVelocity.revolutionPerHour,
        isTrue,
      );

      const newConfig = SensorConfig(
        targetUnit: AngularVelocity.degreesPerMinute,
        targetPrecision: 6,
        timeInterval: Duration(seconds: 2),
      );

      expect(
        await sensorManager.setSensorConfig(SensorId.gyroscope, newConfig),
        SensorTaskResult.success,
      );
    });
  });
}
