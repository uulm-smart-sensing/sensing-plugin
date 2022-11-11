import Flutter
import UIKit

public class SwiftSensingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sensing_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftSensingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
