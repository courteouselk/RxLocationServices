//
//  DeferredLocationUpdatesTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 13/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation
import RxSwift

final class DeferredLocationUpdatesTracker: LocationTracker {

    private static let terminalCLErrorCodes: Set<Int> = [
        CLError.deferredFailed.rawValue, CLError.deferredNotUpdatingLocation.rawValue,
        CLError.deferredAccuracyTooLow.rawValue, CLError.deferredDistanceFiltered.rawValue,
        CLError.denied.rawValue
    ]

    private let deferredDistance: CLLocationDistance
    private let deferredTimeout: TimeInterval

    init(deferredDistance: CLLocationDistance, deferredTimeout: TimeInterval, activityType: CLActivityType, accuracyForNavigation: Bool) {
        self.deferredDistance = deferredDistance
        self.deferredTimeout = deferredTimeout

        super.init(backgroundUpdates: true)

        manager.activityType = activityType
        manager.desiredAccuracy = accuracyForNavigation ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
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

    override func handleUpdateLocations(_ locations: [CLLocation]) {
        super.handleUpdateLocations(locations)

        if !_deferringAllowed.value && CLLocationManager.deferredLocationUpdatesAvailable() {
            _deferringAllowed.value = true
            manager.allowDeferredLocationUpdates(untilTraveled: deferredDistance, timeout: deferredTimeout)
        }
    }

    override func handleFinishDeferredUpdatesWithError(_ error: Error?) {
        _deferringAllowed.value = false

        if let error = error {
            handleError(error)
        }
    }
    
}

#endif
