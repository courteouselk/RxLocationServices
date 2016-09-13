//
//  RxLocationManager.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

public final class RxLocationManager {

    enum Failure: Error {

        /// App is denied to use location services. Please abort your attempt to use them.
        case locationServicesDenied

        /// Location services are restricted. Please abort your attempt to use them.
        case locationServicesRestricted

        /// App is authorized to use location services when in use only.
        case locationServicesAuthorizedWhenInUseOnly

        /// Standard location services are not available.
        case standardLocationServicesUnavailable

        /// Deferred location services are not available.
        case defelledLocationServicesUnavailable

        /// Significant location change services are not available.
        case significantLocationChangeServicesUnavailable

    }

    static let serialScheduler = SerialDispatchQueueScheduler.init(internalSerialQueueName: "nl.northernforest.rxlocationmanager")

}
