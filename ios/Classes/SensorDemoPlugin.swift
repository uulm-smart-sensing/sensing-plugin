import Flutter
import UIKit

//public class SwiftSensorDemoPlugin: NSObject, FlutterPlugin {
//  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "sensor_demo", binaryMessenger: registrar.messenger())
//    let instance = SwiftSensorDemoPlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
//  }
//
//  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    result("iOS " + UIDevice.current.systemVersion)
//  }
//}

public class SensorDemoPlugin: NSObject, FlutterPlugin, FLTApi2Host {
    private let registrar: FlutterPluginRegistrar
    public let accelerometerStreamHandler = AccelerometerStreamHandler()
    public let gyroscopeStreamHandler = GyroscopeStreamHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : FLTApi2Host & NSObjectProtocol = SensorDemoPlugin.init(registrar: registrar)
        FLTApi2HostSetup(messenger, api)
        
    }
    
    init(registrar: FlutterPluginRegistrar) {
           self.registrar = registrar
       }
    
    public func isSensorAvailableSensorId(_ sensorId: NSNumber, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        let id = sensorId as! Int
        let isAvailable = isSensorAvailable(sensorId: id) as NSNumber
        // do not provide nil as FlutterError
        completion(isAvailable, nil)
    }
    
    public func updateSensorIntervalSensorId(_ sensorId: NSNumber, newInterval: NSNumber, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        let id = sensorId as! Int
        let interval = newInterval as! Double
        let isSensorIntervalUpdated = updateSensorInterval(sensorId: id, interval: interval) as NSNumber
        // do not provide nil as FlutterError/
        completion(isSensorIntervalUpdated, nil)
    }
    
    public func startEventChannelSensorId(_ sensorId: NSNumber, interval: NSNumber, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        let id = sensorId as! Int
        let interval = interval as! Double
        let isSensorIntervalUpdated = updateSensorInterval(sensorId: id, interval: interval)
        var isStarted = false;
        if (isSensorIntervalUpdated) {
            isStarted = startEventChannel(sensorId: id, interval: interval)
        }
        // do not provide nil as FlutterError/
        completion(isStarted as NSNumber, nil)
    }
    
    public static func notify(sensorId:Int, sensorData:[Double], eventSink:FlutterEventSink){
        let data = [
            "sensorId": sensorId,
            "data": sensorData,
            "accuracy": 3 //iOS does not send this value so we will match it to the value of high accuracy of Android which is 3
            ] as [String : Any]
        eventSink(data)
    }
    
    private func isSensorAvailable(sensorId: Int)->Bool{
        var isAvailable = false
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            isAvailable = accelerometerStreamHandler.isAvailable()
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            isAvailable = gyroscopeStreamHandler.isAvailable()
            break
        default:
            isAvailable = false
            break
        }
        return isAvailable
    }
    
    private func updateSensorInterval(sensorId: Int, interval: Double)->Bool{
        var isUpdated = false;
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            accelerometerStreamHandler.setInterval(interval: interval)
            isUpdated = true
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            gyroscopeStreamHandler.setInterval(interval: interval)
            isUpdated = true
            break
        default:
            break
        }
        return isUpdated
    }
    
    private func startEventChannel(sensorId: Int, interval: Double)->Bool{
        var started = true
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            let accelerometerEventChannel = FlutterEventChannel(name:"sensors/\(AccelerometerStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
            accelerometerEventChannel.setStreamHandler(accelerometerStreamHandler)
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            let gyroscopeEventChannel = FlutterEventChannel(name:"sensors/\(GyroscopeStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
            gyroscopeEventChannel.setStreamHandler(gyroscopeStreamHandler)
            break
        default:
            started = false
            break
        }
        return started
    }
}
