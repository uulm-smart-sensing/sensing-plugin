//
//  OrientationSensorHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 24.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the sensor for measuring the orientation angles,
 the so called "attitude".
 
 The ``OrientationSensorHandler`` wraps the part of the ``CMMotionManager``,
 which handles the "orientation"  sensor.
 
 So this handler provide methods to ...
 - check, whether the "orientation" sensor is available or already used
 - change the time interval at which the "orientation" sensor data are collected
    or more detailed, at which frequency the data are sent
 - "start" and "stop" the "orientation" sensor, so whether the "orientation" sensor should
    provide orientation angles  data or not
 
 Orientation angles are called "roll", "pitch" and "yaw" and define the angle of rotation
 around the x,y and z axis of the device.
 
 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.
 
 */
public class OrientationSensorHandler: NSObject, ISensorStreamHandler {

    func isSensorAvailable() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionAvailable
    }

    func isSensorUsed() -> Bool {
        return ManagerCollection.getMotionManager().isDeviceMotionActive
    }

    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        let updateTimeInterval : Double = Double(timeInterval) / 1000
        ManagerCollection.getMotionManager().deviceMotionUpdateInterval = updateTimeInterval

        return ResultWrapper(state: SensorTaskResult.success)
    }

    // TODO: check the accuracy of the heading sensor and do not return -1 (indicating no information) as accuracy
    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(ManagerCollection.getMotionManager().deviceMotionUpdateInterval
                                                  * 1000)
        return SensorInfo(unit: Unit.radians, accuracy: SensorAccuracy.high,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotionData: CMDeviceMotion?, err: Error?) in
                guard err != nil else {
                    // multiplying "roll" and "pitch" with negative one to get the same sign / orientation like described
                    // in the Android documentation
                    // (see https://developer.android.com/guide/topics/sensors/sensors_position#sensors-pos-orient)
                    let roll = -1 * (deviceMotionData?.attitude.roll)!
                    let pitch = -1 * (deviceMotionData?.attitude.pitch)!
                    let yaw = deviceMotionData?.attitude.yaw
                    
                    let timestamp = TimestampConverter.convertSensorEventToUnixTimestamp(
                        sensorEventTimestamp: deviceMotionData!.timestamp)

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [roll, pitch, yaw],
                                                maxPrecision: -1,
                                                unit: Unit.radians,
                                                timestampInMicroseconds: timestamp)

                    events(sensorData.toList())
                    
                    return
                }
            })
            
            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Orientation sensor is not available, so it cannot be started.",
                            details: "")
    }

    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getMotionManager().stopDeviceMotionUpdates()
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Orientation sensor is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
