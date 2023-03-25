//
//  BarometerHandler.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 23.03.23.
//

import Foundation
import CoreMotion

/**
 The object for starting and stopping the barometer sensor and receiving its sensor data

 The ``BarometerHandler``wraps the part of the ``CMAltimeter``, which handles the
 magnetometer sensor.

 So this handler provide methods to ...
 - check, whether the barometer is available or already used
 - change the time interval at which the barometer data are collected
 - "start" and "stop" the barometer, so whether the barometer should provide pressure data or not

 - Important: Therefor it conforms the ``ISensorStreamHandler`` protocol, so it
 can be called and managed by the ``SensorManager``.

 */
public class BarometerHandler: NSObject, ISensorStreamHandler {

    /// A Boolean value that indicates whether the barometer is in use or not (so already started or not)
    private var isBarometerInUse: Bool

    /// The interval, in seconds, at which this sensor provide sensor data, i. e. the pressure
    private var requestUpdateTimeInterval: TimeInterval

    /// The timer which sends the latest sensor data from the barometer to the
    /// sensor manager in the smart sensing library
    private var pressurePublisher: Timer?

    /// The latest sensor data, i. e. the last pressure data received from the barometer
    private var latestPressureValue: Double

    /**
     initializes resp. creating a new barometer
     */
    override init() {
        self.isBarometerInUse = false
        self.requestUpdateTimeInterval = 0
        self.pressurePublisher = nil
        self.latestPressureValue = 0.0
    }

    func isSensorAvailable() -> Bool {
        return CMAltimeter.isRelativeAltitudeAvailable()
    }

    func isSensorUsed() -> Bool {
        return self.isBarometerInUse
    }

    func changeSensorTimeInterval(timeInterval: Int64) -> ResultWrapper {
        // convert time interval from miliseconds into seconds
        self.requestUpdateTimeInterval = Double(timeInterval) / 1000

        return ResultWrapper(state: SensorTaskResult.success)
    }

    func getSensorInfo() -> SensorInfo {
        // convert time interval from seconds to milliseconds
        let timeIntervalInMilliSec: Int64 = Int64(self.requestUpdateTimeInterval * 1000)
        return SensorInfo(unit: Unit.kiloPascal, accuracy: SensorAccuracy.high,
                          timeIntervalInMilliseconds: timeIntervalInMilliSec)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if isSensorAvailable() {

            ManagerCollection.getAltimeter().startRelativeAltitudeUpdates(to: OperationQueue.current!,
                                                  withHandler: {(pressureData: CMAltitudeData?, err: Error?) in
                guard err != nil else {
                    self.latestPressureValue = pressureData!.pressure.doubleValue
                    return
                }
            })

            self.isBarometerInUse = true

            // create timer for sending the heading angles
            if self.pressurePublisher == nil {
                self.pressurePublisher = Timer(fire: Date(), interval: requestUpdateTimeInterval, repeats: true,
                                                   block: { (_) in

                    // check, if the app is still allowed to send sensor data
                    if self.isSensorAvailable() {

                        // send the latest heading angle
                        let sensorData = SensorData(data: [self.latestPressureValue], maxPrecision: -1,
                                                    unit: Unit.kiloPascal,
                                                    timestampInMicroseconds: Int64(NSDate().timeIntervalSince1970
                                                                                   * 1000 * 1000))
                        events(sensorData.toList())
                    }

                })
            }

            // add the timer to the current run loop
            RunLoop.current.add(self.pressurePublisher!, forMode: RunLoop.Mode.default)

            return nil
        }
        return FlutterError(code: "SENSOR_NOT_AVAILABLE",
                            message: "Barometer is not available, so it cannot be started.",
                            details: "")
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if isSensorUsed() {
            ManagerCollection.getAltimeter().stopRelativeAltitudeUpdates()
            self.pressurePublisher?.invalidate()
            self.pressurePublisher = nil
            self.isBarometerInUse = false
            return nil
        }
        return FlutterError(code: "NO_UPDATE_STOP_POSSIBLE",
                            message: "Barometer is not used, so stopping the updates is not possible.",
                            details: "")
    }

}
