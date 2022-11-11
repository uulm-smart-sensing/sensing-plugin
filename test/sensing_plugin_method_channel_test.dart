import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensing_plugin/sensing_plugin_method_channel.dart';

void main() {
  MethodChannelSensingPlugin platform = MethodChannelSensingPlugin();
  const MethodChannel channel = MethodChannel('sensing_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
