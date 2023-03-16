//
//  MagnetometerHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 13.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the magnetometer sensor and receiving its sensor data
 
 The ``MagnetometerHandler``wraps the part of the ``CMMotionManager``, which handles the
 magnetometer sensor.
 
 So this handler provide methods to ...
 - check, whether the magnetometer is available or already used
 - change the time interval at which the magnetometer data are collected
 - "start" and "stop" the magnetometer, so whether the magnetometer should provide magnetic field data or not
 
 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.
 
 */
public class MagnetometerHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isMagnetometerAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isMagnetometerActive
    }

    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec: TimeInterval = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().magnetometerUpdateInterval = timeIntervalInSec

        return ResultWrapper(state: SensorTaskResult.success)
    }

    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(ManagerCollection.getMotionManager().magnetometerUpdateInterval
                                                  * 1000)
        return SensorInfo(unit: Unit.microTeslas, accuracy: SensorAccuracy.high,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            MotionManager().startMagnetometerUpdates(to: OperationQueue.current!,
                                                  withHandler: {(magnetometerData: CMMagnetometerData?, err: Error?) in
                guard err != nil else {
                    // get sensor values from magnetometer
                    let xValue = magnetometerData?.magneticField.x
                    let yValue = magnetometerData?.magneticField.y
                    let zValue = magnetometerData?.magneticField.z

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [xValue, yValue, zValue],
                                                maxPrecision: -1,
                                                unit: Unit.microTeslas)

                    events(sensorData.toList())
                    return
                }
            })
            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Magnetometer is not available, so it cannot be started.",
                            details: "")
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getMotionManager().stopMagnetometerUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Magnetometer is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
