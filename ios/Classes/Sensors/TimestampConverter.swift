//
//  TimestampConverter.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 19.03.23.
//

import Foundation

/**
 This object converts different formats of timestamps

 For example the timestamps from the sensor data represent the time since the booting process of the device,
 which needs to be converted to unix timestamps.
 */
public class TimestampConverter: NSObject {

    /**
     converts a time stamp of a sensor data to a unix time stamp

     Therefore this method create a `Date()` object at the moment of the sensor event and subtracts the bias
     (= the boot timestamp contained in the `ProcessInfo.processInfo.systemUptime attribute).
     This calculation result in a `Date()` object containing the absolute moment in time, the sensor event
     occurred (and not relative to boot time). This date will be converted into a unix timestamp
     (using the `timeIntervalSince1970` attribute) and returned.

     - Important: The input timestamp coming from the sensor data (i. e. the `timestamp` attribute
                 from the `CMLogItem` class) is not a unix timestamp, but the elapsed time (in sec)
                 since the device was booted.
     - Parameters:
        - sensorEventTimeStamp: the timestamp, at which the sensor data was produced
     - Returns: the timestamp,  at which the sensor data was produced, converted as a unix timestamp (in micro sec)
     */
    public static func convertSensorEventToUnixTimestamp(sensorEventTimestamp: TimeInterval) -> Int64 {
        let timestamp = Date(timeIntervalSinceNow: sensorEventTimestamp) - ProcessInfo.processInfo.systemUptime
        return Int64(timestamp.timeIntervalSince1970 * 1000 * 1000)
    }

}
