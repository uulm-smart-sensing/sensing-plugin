//
//  GyroscopeStreamHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 10.03.23.
//

import Foundation
import CoreMotion

public class GyroscopeHandler : NSObject, ISensorStreamHandler {
    
    static var sensorId: SensorIds = SensorIds.Gyroscope
    
    private var motionManager: CMMotionManager
    
    internal override init() {
        self.motionManager = CMMotionManager()
    }
    
    func isSensorAvailable() -> Bool {
        return self.motionManager.isGyroAvailable
    }
    
    func isSensorUsed() -> Bool {
        return self.motionManager.isGyroActive
    }
    
    /**
     > Warning: The supported time interval depends on device, but it can assumed that it is at least 100Hz. This means,
     > time intervals, which are bigger than 10ms should work without any problems. But if the time interval is smaller than 10ms it is possible,
     > that the update will not be performed or the change can not be notified.
     */
    func changeSensorTimeInterval(timeInterval: Int32) -> StateIndicator {
        // convert time interval from miliseconds into seconds
        let timeIntervalInSec : TimeInterval = Double(timeInterval) / 1000
        self.motionManager.gyroUpdateInterval = timeIntervalInSec;
        
        // TODO: do not always return true, but maybe check, if the time interval is smaller than 10ms and return a warning
        return StateIndicator.init(state: State.success)
    }
    
    // TODO: check the accuracy of the gyroscope and do not return -1 (indicating no information) as accuracy
    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec : Int32 = Int32(self.motionManager.gyroUpdateInterval * 1000)
        return SensorInfo(unit: Unit.radiansPerSecond, accuracy: -1, timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }
    
    // TODO: check, whether timer is not the better solution and provide the data at more precise frequency or if then data would be losen
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if (isSensorAvailable()) {
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: {(gyroscopeData: CMGyroData?, error: Error?) in
                
                if (error == nil) {
                    // get sensor values from gyroscope
                    var xValue = gyroscopeData?.rotationRate.x
                    var yValue = gyroscopeData?.rotationRate.y
                    var zValue = gyroscopeData?.rotationRate.z
                    
                    // TODO: check, what maxPrecision is
                    // wrap the sensor values to `SensorData` object and "send" it to the event stream
                    let sensorData = SensorData(data: [xValue, yValue, zValue], maxPrecision: -1, unit: Unit.radiansPerSecond)
                    
                    events(sensorData)
                } else {
                    return
                    // inform user about error
                    // return FlutterError(code: "SENSOR_DATA_NOT_AVAILABLE", message: "Gyroscope can not provide any sensor data.", details: "")
                }
                
            })
        } else {
            return FlutterError(code: "SENSOR_NOT_AVAILABLE", message: "Gyroscope is not available, so it cannot be started.", details: "")
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if (isSensorUsed()) {
            self.motionManager.stopGyroUpdates()
        } else {
            return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE", message: "Gyroscope is not used, so stopping the updates is not possible.", details: "")
        }
        return nil
    }
    
    
}