//
//  RxStandardLocationTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

final class RxStandardLocationTracker: RxLocationTracker {

    init(desiredAccuracy: CLLocationAccuracy, distanceFilter: Double, requestAuthorizeAlways: Bool) {
        super.init(requestAuthorizeAlways: requestAuthorizeAlways)

        manager.desiredAccuracy = desiredAccuracy
        manager.distanceFilter = distanceFilter
    }

    override func requestAuthorization() {
        super.requestAuthorization()

        if !CLLocationManager.locationServicesEnabled() {
            let error = RxLocationTracker.Failure.standardLocationServicesUnavailable
            _rx_error.onNext(error)
            _rx_location.onError(error)
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
