//
//  RxLocationTracker.swift
//  RxLocationManager
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

public class RxLocationTracker {

    // MARK: - Public API

    /// Creates a standard location tracker instance.
    ///
    /// The standard location service is most appropriate for apps that deliver location-related
    /// information directly to the user but it may be used by other types of apps too.
    ///
    /// Never specify an accuracy value greater than what you need. Core Location uses the accuracy
    /// value you specify to manage power better. A higher degree of accuracy requires more precise
    /// hardware like GPS, which consumes more power.

    public static func standardTracker(desiredAccuracy desiredAccuracy: CLLocationAccuracy, distanceFilter: Double) -> RxLocationTracker {
        return RxStandardLocationTracker(desiredAccuracy: desiredAccuracy, distanceFilter: distanceFilter)
    }

    /// Creates a signingicant-change tracker instance.
    ///
    /// The significant location change service is better suited for apps that want to get the
    /// user’s initial location and then only want to know when that location changes. This service
    /// requires the presence of cellular hardware and delivers events less frequently than the
    /// standard location services.

    public static func significantChangeTracker() -> RxLocationTracker {
        return RxSignificantChangeLocationTracker()
    }

    /// The accuracy of the location data.
    ///
    /// - seealso: Documentation for [`CLLocationManager.desiredAccuracy`](xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1151/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html).

    public var desiredAccuracy: CLLocationAccuracy { return locationManager.desiredAccuracy }

    /// The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
    ///
    /// - seealso: Documentation for [`CLLocationManager.distanceFilter`](xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1151/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html).

    public var distanceFilter: Double { return locationManager.distanceFilter }

    /// The most recently retrieved user location.
    ///
    /// The value of this property is `nil` if no location data has ever been retrieved.
    ///
    /// - seealso: Documentation for [`CLLocationManager.location`](xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1151/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html)

    public var location: CLLocation? {
        return locationManager.location
    }

    /// Reactive wrapper for most recently retreived user location.

    public var rx_location: Observable<CLLocation> {
        return _rx_location.asObservable()
    }

    // MARK: - Internal API

    class LocationDelegate: NSObject {
        unowned let tracker: RxLocationTracker
        init(tracker: RxLocationTracker) {
            self.tracker = tracker
        }
    }

    // MARK:

    let locationManager = CLLocationManager()
    var locationDelegate: LocationDelegate! = nil
    let _rx_location = ReplaySubject<CLLocation>.create(bufferSize: 1)

    // MARK:

    init() {
        locationDelegate = LocationDelegate(tracker: self)
        locationManager.delegate = locationDelegate
    }

    deinit {
        stopMonitoring()
    }

    // MARK:

    func startMonitoring() { }

    func stopMonitoring() { }

    // MARK:

    func updateLocations(locations: [CLLocation]) {
        locations.forEach {
            _rx_location.onNext($0)
        }
    }

}

// MARK: - CLLocationManagerDelegate

extension RxStandardLocationTracker.LocationDelegate: CLLocationManagerDelegate {

    #if os(iOS)

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        tracker.updateLocations(locations)
    }

    #elseif os(OSX)

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        guard let locations = locations as? [CLLocation] else { return }
        tracker.updateLocations(locations)
    }
    
    #endif
    
}
