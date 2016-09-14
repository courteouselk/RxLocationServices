//
//  LocationTracker+Delegate.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 13/09/2016.
//  Copyright © 2016 northernForest. All rights reserved.
//

import Foundation
import CoreLocation

extension LocationTracker {

    class Delegate: NSObject, CLLocationManagerDelegate {

        unowned let master: LocationTracker

        init(master: LocationTracker) {
            self.master = master
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handleUpdateLocations(locations)
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handleChangeAuthorizationStatus(status)
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handleError(error)
        }

        #if os(iOS)

        func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handlePauseLocationUpdates()
        }

        func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handleResumeLocationUpdates()
        }

        #endif

        func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
            assert(manager === master, "Only can handle calls for the master's location manager.")
            master.handleFinishDeferredUpdatesWithError(error)
        }

    }
    
}
