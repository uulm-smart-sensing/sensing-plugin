//
//  HeadingSensorHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 16.03.23.
//

import Foundation
import CoreLocation

/**
 The object for starting and stopping the sensor for measuring the heading angle.
 
 The ``HeadingSensorHandler`` wraps the part of the ``CLLocationManager``,
 which handles the heading  sensor.
 
 So this handler provide methods to ...
 - check, whether the heading sensor is available or already used
 - change the time interval at which the heading sensor data are collected
    or more detailed, at which frequency the data are sent
 - "start" and "stop" the heading sensor, so whether the heading sensor should
    provide heading angle  data or not
 
 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.
 
 */
public class HeadingSensorHandler: NSObject, ISensorStreamHandler, CLLocationManagerDelegate {

    private var isSensorUsageAllowedFromUser: Bool
    private var isHeadingSensorInUse: Bool
    private var requestUpdateTimeInterval: TimeInterval

    private var headingAnglePublisher: Timer?
    private var latestHeadingValue: Double

    override init() {
        self.isSensorUsageAllowedFromUser = false
        self.isHeadingSensorInUse = false
        self.requestUpdateTimeInterval = 0
        self.headingAnglePublisher = nil
        self.latestHeadingValue = 0.0

        // request user to access location (i. e. heading sensor) data
        ManagerCollection.getLocationManager().requestWhenInUseAuthorization()
    }

    func isSensorAvailable() -> Bool {
        return CLLocationManager.headingAvailable()
    }

    func isSensorUsed() -> Bool {
        return self.isHeadingSensorInUse
    }

    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        self.requestUpdateTimeInterval = Double(timeInterval) / 1000

        return ResultWrapper(state: SensorTaskResult.success)
    }

    // TODO: check the accuracy of the heading sensor and do not return -1 (indicating no information) as accuracy
    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(self.requestUpdateTimeInterval * 1000)
        return SensorInfo(unit: Unit.degrees, accuracy: -1,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        ManagerCollection.getLocationManager().delegate = self

        if isSensorAvailable() {
            ManagerCollection.getLocationManager().startUpdatingHeading()

            // create timer for sending the heading angles
            if self.headingAnglePublisher == nil {
                self.headingAnglePublisher = Timer(fire: Date(), interval: requestUpdateTimeInterval, repeats: true,
                                                   block: { (_) in

                    // send the latest heading angle
                    let sensorData = SensorData(data: [self.latestHeadingValue], maxPrecision: -1, unit: Unit.degrees)
                    events(sensorData.toList())

                })
            }

            // add the timer to the current run loop
            RunLoop.current.add(self.headingAnglePublisher!, forMode: RunLoop.Mode.default)

        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Heading sensor is not available, so it cannot be started.",
                            details: "")
    }

    /**
     updates the last received heading angle value
     
     - Parameters:
        - newHeading new `CLHeading` object, containg the heading sensor data
                   (true heading and magnetic heading as well as accuracy etc.)
     */
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.latestHeadingValue = newHeading.trueHeading
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getLocationManager().stopUpdatingHeading()
            self.headingAnglePublisher?.invalidate()
            self.headingAnglePublisher = nil
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Heading sensor is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
