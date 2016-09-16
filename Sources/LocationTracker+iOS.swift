//
//  LocationTracker+iOS.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 12/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

#if os(iOS)

import CoreLocation

extension LocationTracker {

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
    ///   - desiredAccuracy        : The accuracy of the location data.
    ///   - distanceFilter         : The minimum distance (measured in meters) a device must move
    ///                              horizontally before an update event is generated.
    ///   - requestAuthorizeAlways : Whether to requests permission to use location services
    ///                              whenever the app is running (`true`) or only while the app is
    ///                              in the foreground (`false`).  Default value is `false`.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

    public static func standardTracker(desiredAccuracy: CLLocationAccuracy,
                                       distanceFilter: Double,
                                       requestAuthorizeAlways: Bool = false) -> LocationTracker {
        return StandardLocationTracker(
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
    ///   - deferredDistance            : The distance (in meters) from the current location that
    ///                                   must be travelled before event delivery resumes. To
    ///                                   specify an unlimited distance, pass the `CLLocationDistanceMax`
    ///                                   constant.
    ///   - deferredTimeout             : The amount of time (in seconds) from the current time that
    ///                                   must pass before event delivery resumes. To specify an
    ///                                   unlimited amount of time, pass the `CLTimeIntervalMax`
    ///                                   constant.
    ///   - extendAccuracyForNavigation : Deferred location updates are only available in the modes
    ///                                   of `kCLLocationAccuracyBest` or `kCLLocationAccuracyBestForNavigation`.
    ///                                   Setting this parameters to `true` selects the latter,
    ///                                   while the `false` (default) opts for the former.
    ///
    /// - seealso:
    ///   - [CLLocationManager.allowDeferredLocationUpdates(untilTraveled:timeout:)](apple-reference-documentation://hs64cDNHc7)
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW8)
    ///   - [stackoverflow.com](http://stackoverflow.com/a/14509263/1542569)
    ///   - [stackoverflow.com](http://stackoverflow.com/a/26345001/1542569)

    public static func deferredLocationUpdatesTracker(deferredDistance: CLLocationDistance,
                                                      deferredTimeout: TimeInterval,
                                                      extendAccuracyForNavigation: Bool = false) -> LocationTracker {
        return DeferredLocationUpdatesTracker(
            deferredDistance: deferredDistance,
            deferredTimeout: deferredTimeout,
            extendAccuracyForNavigation: extendAccuracyForNavigation
        )
    }

    /// Creates a signingicant-change tracker instance.
    ///
    /// The significant location change service is better suited for apps that want to get the
    /// user’s initial location and then only want to know when that location changes. This service
    /// requires the presence of cellular hardware and delivers events less frequently than the
    /// standard location services.
    ///
    /// The significant location change service delivers events normally while an app is running in 
    /// the foreground or background. For a terminated iOS app, this service relaunches the app to 
    /// deliver events.  Use of this service requires “Always” authorization from the user.
    ///
    /// - important: 
    ///
    ///   Region and visit monitoring are sufficient for most use cases and should always be 
    ///   considered before significant-change location updates.  In the event significant-change
    ///   location updates are needed, keep in mind the following, which can actually result in
    ///   higher energy use if not employed effectively:
    ///   - Significant-change location updates wake the system and your app once every 15 minutes, 
    ///     at minimum, even if no location changes have occurred.
    ///   - Significant-change location updates run continuously, around the clock, until you stop them.
    ///
    /// - seealso:
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW4)

    public static func significantChangeTracker() -> LocationTracker {
        return SignificantLocationChangeTracker()
    }

}
    
#endif
