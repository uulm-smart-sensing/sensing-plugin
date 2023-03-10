//
//  ISensor.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 17.02.23.
//

import Flutter
import Foundation

/**
 enumeration containing the names respectivly the Ids of all implemented sensors
 */
enum SensorIds : CaseIterable {
    case Accelerometer,
         Gyroscope,
         Magnetometer,
         Heading,
         Linear_Acceleromter,
         Barometer,
         Thermometer
}

/**
 Interface for a stream handler of a sensor
 */
protocol ISensorStreamHandler : NSObject, FlutterStreamHandler {
    
    /// the Id of the sensor used for identification
    static var sensorId: SensorIds { get }
    
    /**
     Checks, whether the sensor is available and can provide sensor data
     - Returns: true, if the sensor is currently available and would provide data, if the tracking would be started, otherwise false
     */
    func isSensorAvailable() -> Bool
    
    
    /**
     Checks, whether the sensor is currently used, which means it was started and not stopped yet
     - Returns: true, if the sensor is currently used so being tracked and provide sensor data, otherwise false
     */
    func isSensorUsed() -> Bool
    
    /**
     Changes the interval at which the sensor provide data
     - Parameters:
        - timeInterval: required interval in ms
     - Returns: StateIndicator.sucess if the time interval was changed sucessfully, otherwise StateIndicator.failure
     */
    func changeSensorTimeInterval(timeInterval : Int32) -> StateIndicator
    
    /**
     Get the information about this sensor
     - Returns: SensorInfo object containing information about the unit, accuracy and the time interval at which the data from the sensor are provided
     */
    func getSensorInfo() -> SensorInfo
}
