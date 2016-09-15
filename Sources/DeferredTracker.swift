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

    private static let terminalCLErrorCodes: Set<Int> = [
        CLError.deferredFailed.rawValue, CLError.deferredNotUpdatingLocation.rawValue,
        CLError.deferredAccuracyTooLow.rawValue, CLError.deferredDistanceFiltered.rawValue,
        CLError.denied.rawValue
    ]

    private let deferredDistance: CLLocationDistance
    private let deferredTimeout: TimeInterval

    init(deferredDistance: CLLocationDistance, deferredTimeout: TimeInterval, accuracyForNavigation: Bool) {
        self.deferredDistance = deferredDistance
        self.deferredTimeout = deferredTimeout

        super.init(requestAuthorizeAlways: true)

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

        if !_deferring.value && CLLocationManager.deferredLocationUpdatesAvailable() {
            _deferring.value = true
            manager.allowDeferredLocationUpdates(untilTraveled: deferredDistance, timeout: deferredTimeout)
        }
    }

    override func handleFinishDeferredUpdatesWithError(_ error: Error?) {
        _deferring.value = false

        if let error = error {
            handleError(error)
        }
    }
    
}

#endif
