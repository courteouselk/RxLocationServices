//
//  RxLocationTracker+iOS.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 12/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation

extension RxLocationTracker {

    // MARK: Public API

    /// Creates a standard location tracker instance.
    ///
    /// The standard location service is most appropriate for apps that deliver location-related
    /// information directly to the user but it may be used by other types of apps too.
    ///
    /// Never specify an accuracy value greater than what you need.  Core Location uses the accuracy
    /// value you specify to manage power better.  A higher degree of accuracy requires more precise
    /// hardware like GPS, which consumes more power.
    ///
    /// - parameters:
    ///   - desiredAccuracy : The accuracy of the location data.
    ///   - distanceFilter  : The minimum distance (measured in meters) a device must move
    ///                       horizontally before an update event is generated.
    ///   - requestAuthorizeAlways : Whether to requests permission to use location services
    ///                              whenever the app is running (`true`) or only while the app is
    ///                              in the foreground (`false`).  Default value is `false`.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

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
    /// Use this tracker in situations where you want location data with GPS accuracy but do not 
    /// need to process that data right away.  If your app is in the background and the system is 
    /// able to optimize its power usage, the location manager tells the GPS hardware to store new 
    /// locations internally until the specified distance or timeout conditions are met.  If your 
    /// app is in the foreground, the location manager does not defer the deliver of events but does
    /// monitor for the specified criteria. If your app moves to the background before the criteria 
    /// are met, the location manager may begin deferring the delivery of events.
    ///
    /// - parameters:
    ///   - desiredAccuracy  : The accuracy of the location data.  The only allowed values are 
    ///                        `kCLLocationAccuracyBest` and `kCLLocationAccuracyBestForNavigation`.
    ///   - deferredDistance : The distance (in meters) from the current location that must be 
    ///                        travelled before event delivery resumes. To specify an unlimited 
    ///                        distance, pass the `CLLocationDistanceMax` constant.
    ///   - deferredTimeout  : The amount of time (in seconds) from the current time that must pass 
    ///                        before event delivery resumes. To specify an unlimited amount of 
    ///                        time, pass the `CLTimeIntervalMax` constant.
    ///
    /// - seealso:
    ///   - [CLLocationManager.allowDeferredLocationUpdates(untilTraveled:timeout:)](apple-reference-documentation://hs64cDNHc7)

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
    ///
    /// - parameters:
    ///   - requestAuthorizeAlways : Whether to requests permission to use location services
    ///                              whenever the app is running (`true`) or only while the app is
    ///                              in the foreground (`false`).  Default value is `false`.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

    public static func significantChangeTracker(requestAuthorizeAlways: Bool = false) -> RxLocationTracker {
        return RxSignificantLocationChangeTracker(requestAuthorizeAlways: requestAuthorizeAlways)
    }

}
    
#endif
