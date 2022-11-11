import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sensing_plugin_method_channel.dart';

abstract class SensingPluginPlatform extends PlatformInterface {
  /// Constructs a SensingPluginPlatform.
  SensingPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SensingPluginPlatform _instance = MethodChannelSensingPlugin();

  /// The default instance of [SensingPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSensingPlugin].
  static SensingPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SensingPluginPlatform] when
  /// they register themselves.
  static set instance(SensingPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
