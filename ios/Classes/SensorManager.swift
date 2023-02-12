import Flutter
import UIKit

public class SensorManager: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sensing_plugin", binaryMessenger: registrar.messenger())
    let instance = SensorManager()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
