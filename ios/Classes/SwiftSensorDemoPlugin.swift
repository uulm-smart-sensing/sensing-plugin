import Flutter
import UIKit

public class SwiftSensorDemoPlugin: NSObject, FlutterPlugin, Api2Host {
    private let registrar: FlutterPluginRegistrar
    
    public let accelerometerStreamHandler = AccelerometerStreamHandler()
    public let gyroscopeStreamHandler = GyroscopeStreamHandler()
    
    public static func register(with registrar: FlutterPluginRegistrar){
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : Api2Host & NSObjectProtocol = SwiftSensorDemoPlugin.init(registrar: registrar)
        Api2HostSetup.setUp(binaryMessenger: messenger, api: api)
    }
    
    init(registrar: FlutterPluginRegistrar) {
            self.registrar = registrar
        }
    
    func isSensorAvailable(sensorId: Int32, completion: @escaping (Bool) -> Void) {
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
        completion(isAvailable)
    }

    func updateSensorInterval(sensorId: Int32, newInterval: Int32, completion: @escaping (Bool) -> Void) {
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            accelerometerStreamHandler.setInterval(interval: newInterval)
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            gyroscopeStreamHandler.setInterval(interval: newInterval)
            break
        default:
            break
        }
        completion(true)
    }

    func startEventChannel(sensorId: Int32, interval: Int32, completion: @escaping (Bool) -> Void) {
        var started = true
        switch sensorId {
        case AccelerometerStreamHandler.SENSOR_ID:
            let accelerometerEventChannel = FlutterEventChannel(name:"flutter_sensors/\(AccelerometerStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
            accelerometerEventChannel.setStreamHandler(accelerometerStreamHandler)
            break
        case GyroscopeStreamHandler.SENSOR_ID:
            let gyroscopeEventChannel = FlutterEventChannel(name:"flutter_sensors/\(GyroscopeStreamHandler.SENSOR_ID)", binaryMessenger: registrar.messenger())
            gyroscopeEventChannel.setStreamHandler(gyroscopeStreamHandler)
            break
        default:
            started = false
            break
        }
        completion(started)
    }
    
    public static func notify(sensorId:Int32, sensorData:[Double], eventSink:FlutterEventSink){
        let data = [
            "sensorId": sensorId,
            "data": sensorData,
            "accuracy": 3 //iOS does not send this value so we will match it to the value of high accuracy of Android which is 3
            ] as [String : Any]
        eventSink(data)
    }
}
