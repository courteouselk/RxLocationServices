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
    /// - note: Never specify an accuracy value greater than what you need.  Core Location uses the
    ///         accuracy value you specify to manage power better.  A higher degree of accuracy
    ///         requires more precise hardware like GPS, which consumes more power.
    ///
    /// - parameters:
    ///
    ///   - desiredAccuracy   : The accuracy of the location data.
    ///   - distanceFilter    : The minimum distance (measured in meters) a device must move
    ///                         horizontally before an update event is generated.
    ///   - backgroundUpdates : If set to `true`, will request "always" authorization to receive
    ///                         location updates whenever the app is running (that is, both when it
    ///                         is in the foreground and in the background).  If set to `false`
    ///                         (default), only "while in use" authorization will be requested.
    ///
    /// - seealso:
    ///
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)

    public static func standardTracker(desiredAccuracy: CLLocationAccuracy,
                                       distanceFilter: Double = kCLDistanceFilterNone,
                                       backgroundUpdates: Bool = false) -> LocationTracker {
        return StandardLocationTracker(
            desiredAccuracy: desiredAccuracy,
            distanceFilter: distanceFilter,
            backgroundUpdates: backgroundUpdates
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
    ///
    ///   - deferredDistance      : The distance (in meters) from the current location that
    ///                             must be travelled before event delivery resumes. To
    ///                             specify an unlimited distance, pass the `CLLocationDistanceMax`
    ///                             constant.
    ///   - deferredTimeout       : The amount of time (in seconds) from the current time that
    ///                             must pass before event delivery resumes. To specify an
    ///                             unlimited amount of time, pass the `CLTimeIntervalMax`
    ///                             constant.
    ///   - activityType          : The type of user activity associated with the location updates.
    ///   - accuracyForNavigation : Setting this parameters to `true` selects `kCLLocationAccuracyBestForNavigation`
    ///                             accuracy for the tracker, while `false` (default) will use
    ///                            `kCLLocationAccuracyBest`.  These two modes are the only
    ///                             ones that support deferred updates.
    ///
    /// - seealso:
    ///
    ///   - [CLLocationManager.allowDeferredLocationUpdates](untilTraveled:timeout:)](apple-reference-documentation://hs64cDNHc7)
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW8)
    ///   - [Answer: How to work with deferred location iOS 6?](http://stackoverflow.com/a/14509263/1542569)
    ///   - [Answer: ios deferred location updates fail to defer](http://stackoverflow.com/a/26345001/1542569)

    public static func deferredLocationUpdatesTracker(deferredDistance: CLLocationDistance,
                                                      deferredTimeout: TimeInterval,
                                                      activityType: CLActivityType = CLActivityType.other,
                                                      accuracyForNavigation: Bool = false) -> LocationTracker {
        return DeferredLocationUpdatesTracker(
            deferredDistance: deferredDistance,
            deferredTimeout: deferredTimeout,
            activityType: activityType,
            accuracyForNavigation: accuracyForNavigation
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
    /// the foreground or background.  For a terminated iOS app, this service relaunches the app to
    /// deliver events.  Use of this service requires "Always" authorization from the user.
    ///
    /// - important: 
    ///
    ///   Region and visit monitoring are sufficient for most use cases and should always be 
    ///   considered before significant-change location updates.  In the event significant-change
    ///   location updates are needed, keep in mind the following, which can actually result in
    ///   higher energy use if not employed effectively:
    ///
    ///   - Significant-change location updates wake the system and your app once every 15 minutes, 
    ///     at minimum, even if no location changes have occurred.
    ///   - Significant-change location updates run continuously, around the clock, until you stop them.
    ///
    /// - seealso:
    ///
    ///   - [CLLocationManager](apple-reference-documentation://hs8c5staNS#overview)
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW4)

    public static func significantChangeTracker() -> LocationTracker {
        return SignificantLocationChangeTracker()
    }

}
    
#endif
