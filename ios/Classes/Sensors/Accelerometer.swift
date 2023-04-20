//
//  Accelerometer.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 13.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the accelerometer sensor and receiving its sensor data.

 The ``AccelerometerHandler``wraps the part of the ``CMMotionManager``,
 which handles the accelerometer  sensor.

 So this handler provide methods to ...
 - check, whether the accelerometer is available or already used
 - change the time interval at which the accelerometer data are collected
 - "start" and "stop" the accelerometer, so whether the accelerometer should provide acceleromation data or not

 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.

 */
public class AccelerometerHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionActive
    }

    /**
     - Warning: The supported time interval depends on device, but it can assumed that it is at least 100Hz.
     This means, time intervals, which are bigger than 10ms should work without any problems.
     But if the time interval is smaller than 10ms it is possible,
     that the update will not be performed or the change can not be notified.
     */
    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec: TimeInterval = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().deviceMotionUpdateInterval = timeIntervalInSec

        // check, whether the requested time interval is below 10 ms
        if timeInterval < 10 {
            // return a warning, because depending on the device, it is not ensured,
            // that accelerometer data can be provided in this time interval
            return ResultWrapper(state: SensorTaskResult.warning)
        }

        return ResultWrapper(state: SensorTaskResult.success)
    }

    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(ManagerCollection.getMotionManager().deviceMotionUpdateInterval
                                                  * 1000)
        return SensorInfo(unit: SensorUnit.gravitationalForce, accuracy: SensorAccuracy.high,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startDeviceMotionUpdates(to: OperationQueue.current!,
                                           withHandler: {(accelerometerData: CMDeviceMotion?, err: Error?) in
                guard err != nil else {
                    // get sensor values from accelerometer
                    let xValue = accelerometerData?.gravity.x
                    let yValue = accelerometerData?.gravity.y
                    let zValue = accelerometerData?.gravity.z

                    let timestamp = TimestampConverter.convertSensorEventToUnixTimestamp(
                        sensorEventTimestamp: accelerometerData!.timestamp)

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [xValue, yValue, zValue],
                                                maxPrecision: -1,
                                                unit: SensorUnit.gravitationalForce,
                                                timestampInMicroseconds: timestamp)

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
            ManagerCollection.getMotionManager().stopDeviceMotionUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Accelerometer is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
