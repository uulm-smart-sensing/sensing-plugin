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
 - Important: The "linear accelerometer" measures the acceleration, but
             without considering the acceleration through gravity!
             So besides different values, the ``LinearAccelerometerHandler``
             works exactly like ``AccelerometerHandler``
 */
public class LinearAccelerometerHandler: AccelerometerHandler {

    override public func onListen(withArguments arguments: Any?,
                                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {
            ManagerCollection.getMotionManager().startDeviceMotionUpdates(to: OperationQueue.current!,
                                           withHandler: {(accelerometerData: CMDeviceMotion?, err: Error?) in
                guard err != nil else {
                    // get sensor values from (user) accelerometer
                    let xValue = accelerometerData?.userAcceleration.x
                    let yValue = accelerometerData?.userAcceleration.y
                    let zValue = accelerometerData?.userAcceleration.z

                    let timestamp = TimestampConverter.convertSensorEventToUnixTimestamp(
                        sensorEventTimestamp: accelerometerData!.timestamp)

                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `InternalSensorData` object and "send" it to the event stream
                    let sensorData = InternalSensorData(data: [xValue, yValue, zValue],
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
}
