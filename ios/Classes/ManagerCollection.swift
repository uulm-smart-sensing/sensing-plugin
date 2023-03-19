//
//  CMManagerCollection.swift
//  sensing_plugin
//
//  Created by Leonhard Alkewitz on 11.03.23.
//

import Foundation
import CoreMotion
import CoreLocation

/**
 This object is a collection of all needed "sensor manager" existing in Swift, which can be used to access sensors
 
 Therefor this class provide instances for the different manager (simalar to a collection singleton instances), so the
 different sensor stream handler can access them.
 - Important: This collection is used to prevent, that the manager (e. g. the CMMotionManager) are created
              multiple times, because this is not recommended (c. f. official Swift documentation for
              CMMotionManager)
 */
public class ManagerCollection: NSObject {

    private static var motionManager: CMMotionManager?
    private static var locationManager: CLLocationManager?

    static func getMotionManager() -> CMMotionManager {
        if self.motionManager == nil {
            self.motionManager = CMMotionManager()
        }

        return self.motionManager!
    }

    static func getLocationManager() -> CLLocationManager {
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
        }

        return self.locationManager!
    }
}
