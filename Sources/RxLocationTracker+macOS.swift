//
//  RxLocationTracker+macOS.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 12/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(macOS)

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
    ///
    /// - parameters:
    ///   - desiredAccuracy : The accuracy of the location data.
    ///   - distanceFilter  : The minimum distance (measured in meters) a device must move
    ///                       horizontally before an update event is generated.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

    public static func standardTracker(desiredAccuracy: CLLocationAccuracy,
                                       distanceFilter: Double) -> RxLocationTracker {
        return RxStandardLocationTracker(
            desiredAccuracy: desiredAccuracy,
            distanceFilter: distanceFilter,
            requestAuthorizeAlways: true
        )
    }

    /// Creates a signingicant-change tracker instance.
    ///
    /// The significant location change service is better suited for apps that want to get the
    /// user’s initial location and then only want to know when that location changes. This service
    /// requires the presence of cellular hardware and delivers events less frequently than the
    /// standard location services.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

    public static func significantChangeTracker() -> RxLocationTracker {
        return RxSignificantLocationChangeTracker(requestAuthorizeAlways: true)
    }

}
    
#endif
