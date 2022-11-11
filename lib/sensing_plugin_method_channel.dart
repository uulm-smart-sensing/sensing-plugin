import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sensing_plugin_platform_interface.dart';

/// An implementation of [SensingPluginPlatform] that uses method channels.
class MethodChannelSensingPlugin extends SensingPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sensing_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
