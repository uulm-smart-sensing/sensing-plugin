//
//  NotImplementedError.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 17.02.23.
//

import Foundation

/// Describes an error in context of method implementation
enum ImplementationError : Error {
    
    /// Indicate that a certain method is not implemented yet
    /// - parameter methodName Name of the method, which is not being implemented yet
    case notImplementedYet(methodName : String)
}
