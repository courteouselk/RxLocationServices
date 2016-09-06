//
//  RxSignificantChangeLocationTracker.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

class RxSignificantChangeLocationTracker: RxLocationTracker {

    override init() {
        super.init()
    }

    override func startMonitoring() {
        locationManager.startMonitoringSignificantLocationChanges()
    }

    override func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

}
