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
        return false
    }
    
    func isSensorUsed() -> Bool {
        return false
    }
    
    func changeSensorTimeInterval(timeInterval: Int32) -> StateIndicator {
        return StateIndicator.init(state: State.fail)
    }
    
    func getSensorInfo() -> SensorInfo {
        return SensorInfo(unit: Unit.unitless, accuracy: 0, timeIntervalInMilliseconds: 0)
    }
    
    // called, when the sensor tracking was started
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    // called, when the sensor tracking was stopped
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    
}
