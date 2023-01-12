import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSensingPluginPlatform
    with MockPlatformInterfaceMixin
    implements SensingPluginPlatform {
  // TODO: Add mocked methods
}

void main() {
  final SensingPluginPlatform initialPlatform = SensingPluginPlatform.instance;

  test('$DummyPluginPlatform is the default instance', () {
    expect(initialPlatform, isInstanceOf<DummyPluginPlatform>());
  });

  // TODO: Add tests for API methods
}
