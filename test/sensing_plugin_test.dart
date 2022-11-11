import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin.dart';
import 'package:sensing_plugin/sensing_plugin_platform_interface.dart';
import 'package:sensing_plugin/sensing_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSensingPluginPlatform
    with MockPlatformInterfaceMixin
    implements SensingPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SensingPluginPlatform initialPlatform = SensingPluginPlatform.instance;

  test('$MethodChannelSensingPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSensingPlugin>());
  });

  test('getPlatformVersion', () async {
    SensingPlugin sensingPlugin = SensingPlugin();
    MockSensingPluginPlatform fakePlatform = MockSensingPluginPlatform();
    SensingPluginPlatform.instance = fakePlatform;

    expect(await sensingPlugin.getPlatformVersion(), '42');
  });
}
