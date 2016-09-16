//
//  StandardLocationTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

final class StandardLocationTracker: LocationTracker {

    init(desiredAccuracy: CLLocationAccuracy, distanceFilter: Double, backgroundUpdates: Bool) {
        super.init(backgroundUpdates: backgroundUpdates)

        manager.desiredAccuracy = desiredAccuracy
        manager.distanceFilter = distanceFilter
    }

    override func requestAuthorization() {
        super.requestAuthorization()

        if !CLLocationManager.locationServicesEnabled() {
            handleError(Failure.standardLocationServicesUnavailable)
        }
    }
    
    override func startTracking() {
        super.startTracking()
        manager.startUpdatingLocation()
    }

    override func stopTracking() {
        manager.stopUpdatingLocation()
        super.stopTracking()
    }

}
