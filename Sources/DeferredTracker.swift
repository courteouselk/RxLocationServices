//
//  DeferredTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 13/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation
import RxSwift

final class DeferredTracker: LocationTracker {

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
            handleError(Failure.standardLocationServicesUnavailable)
        } else if !CLLocationManager.deferredLocationUpdatesAvailable() {
            handleError(Failure.deferredLocationServicesUnavailable)
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

    override func handleFinishDeferredUpdatesWithError(_ error: Error?) {
        if let error = error {
            handleError(error)
        }

        manager.allowDeferredLocationUpdates(untilTraveled: deferredDistance, timeout: deferredTimeout)
    }

}

#endif
