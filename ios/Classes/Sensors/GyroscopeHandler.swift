//
//  GyroscopeStreamHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 10.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the gyroscope sensor and receiving its sensor data

 The ``GyroscopeHandler``wraps the part of the ``CMMotionManager``, which handles the
 gyroscope sensor.

 So this handler provide methods to ...
 - check, whether the gyroscope is available or already used
 - change the time interval at which the gyroscope data are collected
 - "start" and "stop" the gyroscope, so whether the gyroscope should provide rotation data or not

 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.

 */
public class GyroscopeHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isGyroAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isGyroActive
    }

    /**
     - Warning: The supported time interval depends on device, but it can assumed that it is at least 100Hz. This means,
     time intervals, which are bigger than 10ms should work without any problems.
     But if the time interval is smaller than 10ms it is possible,
     that the update will not be performed or the change can not be notified.
     */
    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec: TimeInterval = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().gyroUpdateInterval = timeIntervalInSec

        // check, whether the requested time interval is below 10 ms
        if timeInterval < 10 {
            // return a warning, because depending on the device, it is not ensured,
            // that gyroscope data can be provided in this time interval
            return ResultWrapper(state: SensorTaskResult.warning)
        }

        return ResultWrapper(state: SensorTaskResult.success)
    }

    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(ManagerCollection.getMotionManager().gyroUpdateInterval * 1000)
        return SensorInfo(unit: Unit.radiansPerSecond, accuracy: SensorAccuracy.high,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    // TODO: check, whether timer is not the better solution and provide the data at more precise frequency or
    // if then data would be losen
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startGyroUpdates(to: OperationQueue.current!,
                                                              withHandler: {(gyroscopeData: CMGyroData?, err: Error?) in
                guard err != nil else {
                    // get sensor values from gyroscope
                    let xValue = gyroscopeData?.rotationRate.x
                    let yValue = gyroscopeData?.rotationRate.y
                    let zValue = gyroscopeData?.rotationRate.z

                    let timestamp = TimestampConverter.convertSensorEventToUnixTimestamp(
                        sensorEventTimestamp: gyroscopeData!.timestamp)

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [xValue, yValue, zValue],
                                                maxPrecision: -1,
                                                unit: Unit.radiansPerSecond,
                                                timestampInMicroseconds: timestamp)

                    events(sensorData.toList())
                    return
                }
            })
            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Gyroscope is not available, so it cannot be started.",
                            details: "")
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getMotionManager().stopGyroUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Gyroscope is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
