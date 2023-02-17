import Flutter
import UIKit
import CoreMotion

/**
    The object for managing the different sensors implement on the iOS platform
 
    Use the ``SensorManager`` to manage sensors on iOS platform, so if you want
    1.  check, whether a sensor is currently available on the device (e. g. your iPhone)
    2.  check, whether a sensor is currently used so providing sensor data
    3.  start and stop the tracking of a certain sensor
    4.  change the frequency, how often a certain sensor should provide sensor data
    5.  to get information about a certain sensor, like the unit or accuracy of its sensor data
 
    - Note: The main task of the ``SensorManager`` is to kind of delegate the method calls to the corresponding sensor and return the result from the sensor to the `SensorManager` on Dart platform.
 
    - Important: This class is not intended to be used directly. It will be automatically used by the `SensorManager` on Dart platform, so the method calls
    on Dart platform will automatically trigger the equally named method in this platform specific ``SensorManager`` because the connecting code was generated via Pigeon already (see `Generated/ApiSensorManager`)
 
 */
public class SensorManager: NSObject, FlutterPlugin, SensorManagerApi {

    private let eventChannels : [SensorId : FlutterEventChannel] = [:]
    private let streamHandlers : [SensorId : ISensorStreamHandler] = [:]
    
    private let registrar : FlutterPluginRegistrar
    
    /**
     register the context for the Flutter plugin and setup the channel for the communication between Dart and iOS via Pigeon
     - Note: This method is auto-generated and need to be implemented to use this class in a Flutter plugin
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : SensorManagerApi & NSObjectProtocol = SensorManager.init(registrar: registrar)
        SensorManagerApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
    
    /**
     initializes the ``SensorManager``
     */
    // TODO: add initilization of channels and handlers and document it
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }
    
    // TODO: implement and document this method
    func isSensorAvailable(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "isSensorAvailable")))
    }
    
    // TODO: implement and document this methody
    func isSensorUsed(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "isSensorUsed")))
    }
    
    // TODO: implement and document this method
    func startSensorTracking(id: SensorId, timeIntervalInMilliseconds: Int32, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "startSensorTracking")))
    }
    
    // TODO: implement and document this method
    func stopSensorTracking(id: SensorId, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "stopSensorTracking")))
    }
    
    // TODO: implement and document this method
    func changeSensorTimeInterval(timeIntervalInMilliseconds: Int32, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "changeSensorTimeInterval")))
    }
    
    // TODO: implement and document this method
    func getSensorInfo(id: SensorId, completion: @escaping (Result<SensorInfo, Error>) -> Void) {
        completion(.failure(ImplementationError.notImplementedYet(methodName: "getSensorInfo")))
    }
    
}
