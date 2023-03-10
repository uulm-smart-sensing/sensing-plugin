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
    // TODO: check error handling in methods
    
    private var eventChannels : [SensorId : FlutterEventChannel] = [:]
    private var streamHandlers : [SensorId : ISensorStreamHandler] = [:]
    
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
        
        // add gyroscope as implemented sensor
        streamHandlers.updateValue(GyroscopeHandler(), forKey: SensorId.gyroscope)
    }
    
    func isSensorAvailable(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(id)) {
            // delegate method to sensor and return its answer
            let isSensorAvailable = streamHandlers[id]!.isSensorAvailable();
            completion(.success(isSensorAvailable))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorAvailable", sensorId: id)))
    }
    
    func isSensorUsed(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(id)) {
            // delegate method to sensor and return its answer
            let isSensorUsed = streamHandlers[id]!.isSensorUsed();
            completion(.success(isSensorUsed))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorUsed", sensorId: id)))
    }
    
    func startSensorTracking(id: SensorId, timeIntervalInMilliseconds: Int32, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(id)) {
            // create and save the corresponding eventchannel, if not exist already
            if (eventChannels.keys.contains(id)) {
                var eventChannel = FlutterEventChannel(name:"sensors/\(id)", binaryMessenger: registrar.messenger())
                eventChannels.updateValue(eventChannel, forKey: id)
            }
            
            // start the sensor tracking by update the sampling interval and triggering the onListen method of the sensor stream handler
            let sensorStreamHandler = streamHandlers[id]!
            // TODO: add check of result (catching warning from method)
            sensorStreamHandler.changeSensorTimeInterval(timeInterval: timeIntervalInMilliseconds)
            eventChannels[id]!.setStreamHandler(sensorStreamHandler)
            
            completion(.success(StateIndicator.init(state: State.success)))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorUsed", sensorId: id)))
    }
    
    func stopSensorTracking(id: SensorId, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(id)) {
            // check, whether the sensor with the given Id has a event channel
            if (eventChannels.keys.contains(id)) {
                eventChannels[id]!.setStreamHandler(nil)
                completion(.success(StateIndicator.init(state: State.success)))
            } else {
                completion(.success(StateIndicator.init(state: State.fail)))
            }
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorUsed", sensorId: id)))
    }
    
    // TODO: implement and document this method
    func changeSensorTimeInterval(sensorId: SensorId, timeIntervalInMilliseconds: Int32, completion: @escaping (Result<StateIndicator, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(sensorId)) {
            // delegate method to sensor and return its answer
            let changeTimeInterval = streamHandlers[sensorId]!.changeSensorTimeInterval(timeInterval: timeIntervalInMilliseconds);
            completion(.success(changeTimeInterval))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "changeSensorTimeInterval", sensorId: sensorId)))
    }
    
    func getSensorInfo(id: SensorId, completion: @escaping (Result<SensorInfo, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if (streamHandlers.keys.contains(id)) {
            // delegate method to sensor and return its answer
            let sensorInfo = streamHandlers[id]!.getSensorInfo();
            completion(.success(sensorInfo))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "getSensorInfo", sensorId: id)))
    }
    
    func dummyMethod(data: SensorData) throws {
        throw ImplementationError.notImplementedYet(methodName: "dummyMethod")
    }
    
}
