import 'package:flutter_test/flutter_test.dart';
import 'package:sensor_demo/sensor_demo_pigeon.dart';
import 'package:sensor_demo/sensor_demo_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sensor_demo/sensor_event.dart';

class MockSensorDemoPlatform with MockPlatformInterfaceMixin implements SensorDemoPlatform {
  @override
  Future<bool> isSensorAvailable(int sensorId) => Future.value(true);

  @override
  Future<bool> updateSensorInterval(int sensorId, Duration newInterval) => Future.value(true);

  @override
  Future<Stream<SensorEvent>> sensorUpdates({required int sensorId, Duration? interval}) {
    throw UnimplementedError();
  }
}

void main() {
  final SensorDemoPlatform initialPlatform = SensorDemoPlatform.instance;

  test('$PigeonSensorDemo is the default instance', () {
    expect(initialPlatform, isInstanceOf<PigeonSensorDemo>());
  });
}
