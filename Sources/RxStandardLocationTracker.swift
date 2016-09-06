//
//  RxStandardLocationTracker.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

class RxStandardLocationTracker: RxLocationTracker {

    init(desiredAccuracy: CLLocationAccuracy, distanceFilter: Double) {
        super.init()

        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
    }

    override func startMonitoring() {
        locationManager.stopUpdatingLocation()
    }

    override func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }

}
