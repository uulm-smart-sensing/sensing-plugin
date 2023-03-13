//
//  NotImplementedError.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 17.02.23.
//

import Foundation

/// Describes an error in context of method implementation
enum ImplementationError: Error {

    /// Indicate that a certain method is not implemented yet
    /// - parameter methodName Name of the method, which is not implemented yet
    case notImplementedYet(methodName: String)

    /// Indicate that the requested method is not implemented for the sensor
    /// - parameter methodName Name of the method, which is not  implemented yet
    /// - parameter sensorId the id of the sensor, whose method is not implemented
    case sensorNotImplemented(methodName: String, sensorId: SensorId)
}
