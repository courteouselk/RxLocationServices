//
//  SignificantLocationChangeTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

final class SignificantLocationChangeTracker: LocationTracker {

    init() {
        super.init(requestAuthorizeAlways: true)
    }

    override func requestAuthorization() {
        super.requestAuthorization()

        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            handleError(Failure.significantLocationChangeServicesUnavailable)
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
