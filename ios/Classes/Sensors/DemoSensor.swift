//
//  DemoSensor.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 17.02.23.
//

import Foundation

public class DemoSensor : NSObject, ISensorStreamHandler {
    static var sensorId: Int = 0
    
    func isSensorAvailable() -> Bool {
        <#code#>
    }
    
    func isSensorUsed() -> Bool {
        <#code#>
    }
    
    func changeSensorTimeInterval(timeInterval: Int32) -> StateIndicator {
        <#code#>
    }
    
    func getSensorInfo() -> SensorInfo {
        <#code#>
    }
    
    // called, when the sensor tracking was started
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        <#code#>
    }
    
    // called, when the sensor tracking was stopped
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        <#code#>
    }
    
    
}
