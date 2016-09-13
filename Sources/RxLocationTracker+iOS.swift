//
//  RxLocationTracker+iOS.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 12/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation

extension RxLocationTracker {

    // MARK: - Public API

    /// Creates a standard location tracker instance.
    ///
    /// The standard location service is most appropriate for apps that deliver location-related
    /// information directly to the user but it may be used by other types of apps too.
    ///
    /// Never specify an accuracy value greater than what you need. Core Location uses the accuracy
    /// value you specify to manage power better. A higher degree of accuracy requires more precise
    /// hardware like GPS, which consumes more power.

    public static func standardTracker(desiredAccuracy: CLLocationAccuracy,
                                       distanceFilter: Double,
                                       requestAuthorizeAlways: Bool = false) -> RxLocationTracker {
        return RxStandardLocationTracker(
            desiredAccuracy: desiredAccuracy,
            distanceFilter: distanceFilter,
            requestAuthorizeAlways: requestAuthorizeAlways
        )
    }

    /// Creates a deferred updates location tracker instance.
    ///
    /// 

    public static func deferredTracker(desiredAccuracy: CLLocationAccuracy,
                                       deferredDistance: CLLocationDistance,
                                       deferredTimeout: TimeInterval) -> RxLocationTracker {
        return RxDeferredTracker(
            desiredAccuracy: desiredAccuracy,
            deferredDistance: deferredDistance,
            deferredTimeout: deferredTimeout
        )
    }


    /// Creates a signingicant-change tracker instance.
    ///
    /// The significant location change service is better suited for apps that want to get the
    /// user’s initial location and then only want to know when that location changes. This service
    /// requires the presence of cellular hardware and delivers events less frequently than the
    /// standard location services.

    public static func significantChangeTracker(requestAuthorizeAlways: Bool = false) -> RxLocationTracker {
        return RxSignificantLocationChangeTracker(requestAuthorizeAlways: requestAuthorizeAlways)
    }

}
    
#endif
