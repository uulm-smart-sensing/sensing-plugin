//
//  HeadingSensorHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 16.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the sensor for measuring the heading angle.
 
 The ``HeadingSensorHandler``wraps the part of the ``CMMotionManager``,
 which handles the heading  sensor.
 
 So this handler provide methods to ...
 - check, whether the heading sensor is available or already used (actually the device motion sensor)
 - change the time interval at which the heading sensor data are collected
 - "start" and "stop" the heading sensor (i. e. the device motion sensor),
    so whether the heading sensor should provide heading angle  data or not
 
 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.
 
 */
public class HeadingSensorHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionActive
    }

    func changeSensorTimeInterval(timeInterval: Int32) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec: TimeInterval = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().deviceMotionUpdateInterval = timeIntervalInSec

        return ResultWrapper(state: SensorTaskResult.success)
    }

    // TODO: check the accuracy of the accelerometer and do not return -1 (indicating no information) as accuracy
    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(ManagerCollection.getMotionManager().deviceMotionUpdateInterval
                                                  * 1000)
        return SensorInfo(unit: Unit.degrees, accuracy: -1,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startDeviceMotionUpdates(to: OperationQueue.current!,
                                           withHandler: {(headingData: CMDeviceMotion?, err: Error?) in
                guard err != nil else {
                    // get sensor values from accelerometer
                    let headingAngle = headingData?.heading

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [headingAngle],
                                                maxPrecision: -1,
                                                unit: Unit.gravitationalForce)

                    events(sensorData.toList())
                    return
                }
            })
            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Heading sensor is not available, so it cannot be started.",
                            details: "")
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getMotionManager().stopDeviceMotionUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Heading sensor is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
