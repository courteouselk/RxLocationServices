//
//  RxDeferredTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 13/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation
import RxSwift

final class RxDeferredTracker: RxLocationTracker {

    private let deferredDistance: CLLocationDistance
    private let deferredTimeout: TimeInterval

    init(desiredAccuracy: CLLocationAccuracy, deferredDistance: CLLocationDistance, deferredTimeout: TimeInterval) {
        assert(desiredAccuracy == kCLLocationAccuracyBestForNavigation || desiredAccuracy == kCLLocationAccuracyBest,
               "Desired accuracy must be either kCLLocationAccuracyBestForNavigation or kCLLocationAccuracyBest")

        self.deferredDistance = deferredDistance
        self.deferredTimeout = deferredTimeout

        super.init(requestAuthorizeAlways: true)

        manager.desiredAccuracy = desiredAccuracy
        manager.distanceFilter = kCLDistanceFilterNone
    }

    override func requestAuthorization() {
        super.requestAuthorization()

        if !CLLocationManager.locationServicesEnabled() {
            let error = RxLocationTracker.Failure.standardLocationServicesUnavailable
            _rx_error.onNext(error)
            _rx_location.onError(error)
        }

        if !CLLocationManager.deferredLocationUpdatesAvailable() {
            let error = RxLocationTracker.Failure.deferredLocationServicesUnavailable
            _rx_error.onNext(error)
            _rx_location.onError(error)
        }
    }

    override func startTracking() {
        super.startTracking()
        manager.startUpdatingLocation()
        manager.allowDeferredLocationUpdates(untilTraveled: deferredDistance, timeout: deferredTimeout)
    }

    override func stopTracking() {
        manager.disallowDeferredLocationUpdates()
        manager.stopUpdatingLocation()
        super.stopTracking()
    }

    override func finishDeferredUpdatesWithError(_ error: Error?) {
        if let error = error {
            _rx_error.onNext(error)
            // _rx_location.onError(error)
        }

        manager.allowDeferredLocationUpdates(untilTraveled: deferredDistance, timeout: deferredTimeout)
    }

}

#endif
