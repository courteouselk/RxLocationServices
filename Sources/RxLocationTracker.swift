//
//  RxLocationTracker.swift
//  RxLocationServices
//
//  Created by Anton Bronnikov on 03/09/2016.
//  Copyright © 2016 Anton Bronnikov. All rights reserved.
//

import CoreLocation
import RxSwift

/// Reactive wrapper for location tracking functionality of `CLLocationManager` from `CoreLocation`.
///
/// - note: The following elements might have to be included into your iOS app's `info.plist` file 
///         for this API to work as expected:
///
/// - `NSLocationWhenInUseUsageDescription` with the user prompt text for requesting a permission to 
///    use location services when the app is in use.
/// - `NSLocationAlwaysUsageDescription` with the user prompt text for requesting a permission to 
///    use location services whenever the app is running.
/// - `UIBackgroundModes` includin the `location` value to receive location updates when the app is 
///    suspended.

public class RxLocationTracker {

    // MARK: Public API

    /// The accuracy of the location data.
    ///
    /// - seealso:
    ///   - [CLLocationManager.desiredAccuracy](apple-reference-documentation://hsdIn9h8NI).

    public var desiredAccuracy: CLLocationAccuracy { return manager.desiredAccuracy }

    /// The minimum distance (measured in meters) a device must move horizontally before an update 
    /// event is generated.
    ///
    /// - seealso:
    ///   - [CLLocationManager.distanceFilter](apple-reference-documentation://hsvBsx6Fhd).

    public var distanceFilter: Double { return manager.distanceFilter }

    #if os(iOS)

    /// The type of user activity associated with the location updates.
    ///
    /// - seealso: 
    ///   - [CLLocationManager.activityType](apple-reference-documentation://hsiIxqp5lV)

    public var activityType: CLActivityType {
        get { return manager.activityType }
        set { manager.activityType = newValue }
    }

    /// A Boolean value indicating whether the tracker may pause location updates.
    ///
    /// - seealso:
    ///   - [CLLocationManager.pausesLocationUpdatesAutomatically](apple-reference-documentation://hsrH9OEXi4).

    public var pausesLocationUpdatesAutomatically: Bool {
        get { return manager.pausesLocationUpdatesAutomatically }
        set { manager.pausesLocationUpdatesAutomatically = newValue }
    }

    /// A Boolean value indicating whether the app wants to receive location updates when suspended.
    ///
    /// The default value for this property is `false`.
    ///
    /// If you set this property to `true` please make sure to include the `UIBackgroundModes` key 
    /// with the `location` value in your app’s `info.plist` file.  Please refer to the documentation
    /// on [CLLocationManager.allowsBackgroundLocationUpdates](apple-reference-documentation://hsBpvPO12H)
    /// for further details.
    ///
    /// - seealso:
    ///   - [CLLocationManager.allowsBackgroundLocationUpdates](apple-reference-documentation://hsBpvPO12H)
    ///   - [stackoverflow.com](http://stackoverflow.com/q/30808192/1542569)

    @available(iOS 9.0, *) public var allowsBackgroundLocationUpdates: Bool {
        get { return manager.allowsBackgroundLocationUpdates }
        set { manager.allowsBackgroundLocationUpdates = newValue }
    }

    #endif
    
    /// The most recently retrieved user location.
    ///
    /// The value of this property is `nil` if no location data has ever been retrieved.
    ///
    /// - seealso: [CLLocationManager.location](apple-reference-documentation://hspJvThCV9).

    public var location: CLLocation? { return manager.location }

    /// Reactive wrapper for the most recently retrieved user location.

    public var rx_location: Observable<CLLocation> {
        return _rx_location
            .observeOn(RxLocationTracker.serialScheduler)
            .do(onSubscribe: {
                self.notifySubscribed()
            })
            .do(onDispose: {
                self.notifyUnsubscribed()
            })
            .do(onError: { error in
                self.stopTracking()
            })
    }

    /// Reactive wrapper for paused state of location updates delivery.
    ///
    /// When the location manager detects that the device’s location is not changing, it can pause 
    /// the delivery of updates in order to shut down the appropriate hardware and save power.
    ///
    /// - seealso: 
    ///   - [CLLocationManager.locationManagerDidPauseLocationUpdates(_:)](apple-reference-documentation://hsbKLYxMg0)
    ///   - [CLLocationManager.locationManagerDidResumeLocationUpdates(_:)](apple-reference-documentation://hsRKsf1ayS)

    public var rx_paused: Observable<Bool> { return _rx_paused.asObservable() }

    // MARK: - Internal API

    static let serialScheduler = SerialDispatchQueueScheduler.init(internalSerialQueueName: "nl.northernforest.rxlocationtracker")

    let _rx_location = ReplaySubject<CLLocation>.create(bufferSize: 1)
    let _rx_error = ReplaySubject<Error>.create(bufferSize: 1)
    let _rx_paused = ReplaySubject<Bool>.create(bufferSize: 1)

    let manager = CLLocationManager()
    var delegate: Delegate! = nil

    let requestAuthorizeAlways: Bool

    private var subscribersCount = 0

    // MARK:

    init(requestAuthorizeAlways: Bool) {
        self.requestAuthorizeAlways = requestAuthorizeAlways

        delegate = Delegate(master: self)
        manager.delegate = delegate
    }

    deinit {
        stopTracking()
    }

    /// Starts tracking of the location.

    func startTracking() {
        requestAuthorization()
    }

    /// Stops tracking of the location

    func stopTracking() { }

    /// Once `rx_location` observable is subscribed to, this is called.

    final func notifySubscribed() {
        assert(subscribersCount >= 0, "Subscribers count can not be negative")
        subscribersCount += 1
        if subscribersCount == 1 {
            startTracking()
        }
    }

    /// Once `rx_location` observable is disposed, this is called.

    final func notifyUnsubscribed() {
        subscribersCount -= 1
        assert(subscribersCount >= 0, "Subscribers count can not be negative")
        if subscribersCount == 0 {
            stopTracking()
        }
    }

    // MARK: - Delegate's API

    /// Respond to the updated location events.

    func updateLocations(_ locations: [CLLocation]) {
        locations.forEach {
            _rx_location.onNext($0)
        }
    }

    /// Respond to the event of a change in the authorization status.

    func changeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch (status, requestAuthorizeAlways) {

        case (.restricted, _):
            let error = RxLocationTracker.Failure.locationServicesRestricted
            _rx_error.onNext(error)
            _rx_location.onError(error)


        case (.denied, _):
            let error = RxLocationTracker.Failure.locationServicesDenied
            _rx_error.onNext(error)
            _rx_location.onError(error)

        case (.authorizedWhenInUse, true):
            let error = RxLocationTracker.Failure.locationServicesAuthorizedWhenInUseOnly
            _rx_error.onNext(error)
            _rx_location.onError(error)

        default:
            break

        }
    }

    /// Respond to the event of an error.

    func failWithError(_ error: Error) {
        _rx_error.onNext(error)
        // _rx_location.onError(error)
    }

    /// Respond to the event of a pause in location updates.

    func pauseLocationUpdates() {
        _rx_paused.onNext(true)
    }

    /// Respond to the event of resumed location updates.

    func resumeLocationUpdates() {
        _rx_paused.onNext(false)
    }

    /// Respond to the event of deferred updates finish.

    func finishDeferredUpdatesWithError(_ error: Error?) {
        // Do nothing
    }

    #if os(iOS)

    // MARK: - iOS specific

    /// Checks current authorization, requests one if needed, throws an error if none is given.

    func requestAuthorization() {
        switch (CLLocationManager.authorizationStatus(), requestAuthorizeAlways) {

        case (.restricted, _):
            let error = RxLocationTracker.Failure.locationServicesRestricted
            _rx_error.onNext(error)
            _rx_location.onError(error)

        case (.denied, _):
            let error = RxLocationTracker.Failure.locationServicesDenied
            _rx_error.onNext(error)
            _rx_location.onError(error)

        case (.authorizedWhenInUse, true):
            let error = RxLocationTracker.Failure.locationServicesAuthorizedWhenInUseOnly
            _rx_error.onNext(error)
            _rx_location.onError(error)

        case (.notDetermined, true):
            manager.requestAlwaysAuthorization()

        case (.notDetermined, false):
            manager.requestWhenInUseAuthorization()
            
        default:
            break
            
        }
    }

    #elseif os(macOS)

    // MARK: - macOS specific

    /// Checks current authorization, requests one if needed, throws an error if none is given.

    func requestAuthorization() {
        switch (CLLocationManager.authorizationStatus(), requestAuthorizeAlways) {

        case (.restricted, _):
            let error = RxLocationTracker.Failure.locationServicesRestricted
            _rx_error.onNext(error)
            _rx_location.onError(error)

        case (.denied, _):
            let error = RxLocationTracker.Failure.locationServicesDenied
            _rx_error.onNext(error)
            _rx_location.onError(error)

        default:
            break
            
        }
    }

    #endif

}
