//
//  LinearAccelerometer.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 13.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the accelerometer sensor and receiving its sensor data.
 - Important: The "linear accelerometer" measures the acceleromation, but
             without considering the acceleration through gravity!
 
 The ``LinearAccelerometerHandler``wraps the part of the ``CMMotionManager``,
 which handles the gyroscope sensor.
 
 So this handler provide methods to ...
 - check, whether the accelerometer is available or already used
 - change the time interval at which the accelerometer data are collected
 - "start" and "stop" the accelerometer, so whether the accelerometer should provide acceleromation data or not
 
 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.
 
 */
public class LinearAccelerometerHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isAccelerometerAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isAccelerometerActive
    }

    /**
     - Warning: The supported time interval depends on device, but it can assumed that it is at least 100Hz.
     This means, time intervals, which are bigger than 10ms should work without any problems.
     But if the time interval is smaller than 10ms it is possible,
     that the update will not be performed or the change can not be notified.
     */
    func changeSensorTimeInterval(timeInterval: Int32) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec: TimeInterval = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().accelerometerUpdateInterval = timeIntervalInSec

        // check, whether the requested time interval is below 10 ms
        if timeInterval < 10 {
            // return a warning, because depending on the device, it is not ensured,
            // that gyroscope data can be provided in this time interval
            return ResultWrapper(state: SensorTaskResult.warning)
        }

        return ResultWrapper(state: SensorTaskResult.success)
    }

    // TODO: check the accuracy of the accelerometer and do not return -1 (indicating no information) as accuracy
    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int32 = Int32(ManagerCollection.getMotionManager().accelerometerUpdateInterval
                                                  * 1000)
        return SensorInfo(unit: Unit.gravitationalForce, accuracy: -1,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startAccelerometerUpdates(to: OperationQueue.current!,
                                                   withHandler: {(accelerometerData: CMAccelerometerData?, err: Error?) in
                guard err != nil else {
                    // get sensor values from gyroscope
                    let xValue = accelerometerData?.acceleration.x
                    let yValue = accelerometerData?.acceleration.y
                    let zValue = accelerometerData?.acceleration.z

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [xValue, yValue, zValue],
                                                maxPrecision: -1,
                                                unit: Unit.gravitationalForce)

                    events(sensorData.toList())
                    return
                }
            })
            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Accelerometer is not available, so it cannot be started.",
                            details: "")
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getMotionManager().stopAccelerometerUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Accelerometer is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
