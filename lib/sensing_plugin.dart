
import 'sensing_plugin_platform_interface.dart';

class SensingPlugin {
  Future<String?> getPlatformVersion() {
    return SensingPluginPlatform.instance.getPlatformVersion();
  }
}
