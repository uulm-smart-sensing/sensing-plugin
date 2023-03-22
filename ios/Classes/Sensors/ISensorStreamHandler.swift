//
//  ISensor.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 17.02.23.
//

import Flutter
import Foundation

/**
 Interface for a stream handler of a sensor
 */
protocol ISensorStreamHandler: NSObject, FlutterStreamHandler {

    /**
     Checks, whether the sensor is available and can provide sensor data
     - Returns: true, if the sensor is currently available and would provide data,
                if the tracking would be started, otherwise false
     */
    func isSensorAvailable() -> Bool

    /**
     Checks, whether the sensor is currently used, which means it was started and not stopped yet
     - Returns: true, if the sensor is currently used (so being tracked) and provide sensor data, otherwise false
     */
    func isSensorUsed() -> Bool

    /**
     Changes the interval at which the sensor provide data
     - Parameters:
        - timeInterval: required interval in ms
     - Returns: ResultWrapper if the time interval was changed sucessfully, otherwise StateIndicator.failure
     */
    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper

    /**
     Get the information about this sensor
     - Returns: SensorInfo object containing information about the unit, accuracy and
                the time interval at which the data from the sensor are provided
     */
    func getSensorInfo() -> SensorInfo
}
