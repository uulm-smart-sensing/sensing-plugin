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

 - Note: The main task of the ``SensorManager`` is to kind of delegate the method calls to
 the corresponding sensor and return the result from the sensor to the `SensorManager` on Dart platform.

 - Important: This class is not intended to be used directly. It will be automatically used by
 the `SensorManager` on Dart platform, so the method calls on Dart platform will automatically trigger
 the equally named method in this platform specific ``SensorManager`` because the connecting code was
 generated via Pigeon already (see `Generated/ApiSensorManager`)

 */
public class SensorManager: NSObject, FlutterPlugin, SensorManagerApi {

    private var eventChannels: [SensorId: FlutterEventChannel] = [:]
    private var streamHandlers: [SensorId: ISensorStreamHandler] = [:]

    private let registrar: FlutterPluginRegistrar

    /**
     register the context for the Flutter plugin and setup the channel for the communication between Dart and iOS
     via Pigeon
     - Note: This method is auto-generated and need to be implemented to use this class in a Flutter plugin
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger = registrar.messenger()
        let api: SensorManagerApi & NSObjectProtocol = SensorManager.init(registrar: registrar)
        SensorManagerApiSetup.setUp(binaryMessenger: messenger, api: api)
    }

    /**
     initializes the ``SensorManager``

     Therefor, the `init` method ...
     - save the registration context for the flutter plugin for later use
     - register all implemented stream handlers for the sensors
     */
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar

        // add gyroscope as implemented sensor
        streamHandlers.updateValue(GyroscopeHandler(), forKey: SensorId.gyroscope)

        // add magnetometer as implemented sensor
        streamHandlers.updateValue(MagnetometerHandler(), forKey: SensorId.magnetometer)

        // add (linear) acceleromter as implemented sensor
        streamHandlers.updateValue(LinearAccelerometerHandler(), forKey: SensorId.linearAcceleration)
        streamHandlers.updateValue(AccelerometerHandler(), forKey: SensorId.accelerometer)

        // add heading sensor as implemented sensor
        if #available(iOS 14.0, *) {
            streamHandlers.updateValue(HeadingSensorHandler(), forKey: SensorId.heading)
        }
    }

    func isSensorAvailable(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(id) {
            // delegate method to sensor and return its answer
            let isSensorAvailable = streamHandlers[id]!.isSensorAvailable()
            completion(.success(isSensorAvailable))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorAvailable", sensorId: id)))
    }

    func isSensorUsed(id: SensorId, completion: @escaping (Result<Bool, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(id) {
            // delegate method to sensor and return its answer
            let isSensorUsed = streamHandlers[id]!.isSensorUsed()
            completion(.success(isSensorUsed))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "isSensorUsed", sensorId: id)))
    }

    func startSensorTracking(id: SensorId, timeIntervalInMilliseconds: Int64, completion: @escaping
                             (Result<ResultWrapper, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(id) {
            // create and save the corresponding eventchannel, if not exist already
            if !eventChannels.keys.contains(id) {
                let eventChannel = FlutterEventChannel(name: "sensors/\(id)", binaryMessenger: registrar.messenger())
                eventChannels.updateValue(eventChannel, forKey: id)
            } else {
                completion(.success(ResultWrapper.init(state: SensorTaskResult.alreadyTrackingSensor)))
            }

            // start the sensor tracking by update the sampling interval and
            // triggering the onListen method of the sensor stream handler
            let sensorStreamHandler = streamHandlers[id]!
            let result: ResultWrapper = sensorStreamHandler.changeSensorTimeInterval(timeInterval:
                                                                                        timeIntervalInMilliseconds)
            eventChannels[id]!.setStreamHandler(sensorStreamHandler)

            completion(.success(result))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "startSensorTracking", sensorId: id)))
    }

    func stopSensorTracking(id: SensorId, completion: @escaping (Result<ResultWrapper, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(id) {
            // check, whether the sensor with the given Id has a event channel
            if eventChannels.keys.contains(id) {
                eventChannels[id]!.setStreamHandler(nil)
                eventChannels.removeValue(forKey: id)
                completion(.success(ResultWrapper.init(state: SensorTaskResult.success)))
            } else {
                completion(.success(ResultWrapper.init(state: SensorTaskResult.notTrackingSensor)))
            }
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "stopSensorTracking", sensorId: id)))
    }

    func changeSensorTimeInterval(sensorId: SensorId, timeIntervalInMilliseconds: Int64, completion: @escaping
                                  (Result<ResultWrapper, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(sensorId) {
            // delegate method to sensor and return its answer
            let result: ResultWrapper = streamHandlers[sensorId]!.changeSensorTimeInterval(timeInterval:
                                                                                            timeIntervalInMilliseconds)
            completion(.success(result))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "changeSensorTimeInterval",
                                                                     sensorId: sensorId)))
    }

    func getSensorInfo(id: SensorId, completion: @escaping (Result<SensorInfo, Error>) -> Void) {
        // check, whether the sensor with the given Id is implemented
        if streamHandlers.keys.contains(id) {
            // delegate method to sensor and return its answer
            let sensorInfo = streamHandlers[id]!.getSensorInfo()
            completion(.success(sensorInfo))
        }
        completion(.failure(ImplementationError.sensorNotImplemented(methodName: "getSensorInfo", sensorId: id)))
    }

    // swiftlint:disable:next identifier_name
    func _dummyMethod(data: SensorData) throws {
        throw ImplementationError.notImplementedYet(methodName: "dummyMethod")
    }

}
