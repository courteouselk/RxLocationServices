//
//  RxSignificantLocationChangeTracker.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

final class RxSignificantLocationChangeTracker: RxLocationTracker {

    override func requestAuthorization() {
        super.requestAuthorization()

        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            _rx_location.onError(RxLocationManager.Failure.significantLocationChangeServicesUnavailable)
        }
    }

    override func startTracking() {
        super.startTracking()
        manager.startMonitoringSignificantLocationChanges()
    }

    override func stopTracking() {
        manager.stopMonitoringSignificantLocationChanges()
        super.stopTracking()
    }

}
