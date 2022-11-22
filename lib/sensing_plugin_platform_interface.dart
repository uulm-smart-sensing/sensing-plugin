import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class SensingPluginPlatform extends PlatformInterface {
  SensingPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SensingPluginPlatform _instance = DummyPluginPlatform();

  static SensingPluginPlatform get instance => _instance;

  static set instance(SensingPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}

class DummyPluginPlatform extends SensingPluginPlatform {
  // TODO: Remove
}
