//
//  RxLocationTracker+Delegate.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 13/09/2016.
//  Copyright © 2016 northernForest. All rights reserved.
//

import Foundation
import CoreLocation

extension RxLocationTracker {

    class Delegate: NSObject, CLLocationManagerDelegate {

        unowned let master: RxLocationTracker

        init(master: RxLocationTracker) {
            self.master = master
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.updateLocations(locations)
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.changeAuthorizationStatus(status)
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.failWithError(error)
        }

        #if os(iOS)

        func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.pauseLocationUpdates()
        }

        func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.resumeLocationUpdates()
        }

        #endif

        func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.finishDeferredUpdatesWithError(error)
        }

    }
    
}
