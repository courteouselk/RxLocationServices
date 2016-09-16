//
//  LocationTracker.swift
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

public class LocationTracker {

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
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW7)

    public var pausesLocationUpdatesAutomatically: Bool {
        get { return manager.pausesLocationUpdatesAutomatically }
        set { manager.pausesLocationUpdatesAutomatically = newValue }
    }

    /// A Boolean value indicating whether the app wants to receive location updates when suspended.
    ///
    /// The default value for this property is `false`.
    ///
    /// If you set this property to `true` make sure to include the `UIBackgroundModes` key with
    /// the `location` value in your app’s `info.plist` file.  Please refer to the documentation on
    /// [CLLocationManager.allowsBackgroundLocationUpdates](apple-reference-documentation://hsBpvPO12H)
    /// for further details.
    ///
    /// - seealso:
    ///   - [CLLocationManager.allowsBackgroundLocationUpdates](apple-reference-documentation://hsBpvPO12H)
    ///   - [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW7)
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

    /// The most recent error.
    ///
    /// The value of this property is `nil` if no errors were encountered.
    ///
    /// Typically the error will be either `NSError` from `kCLErrorDomain` or `LocationTracker.Failure`.

    public private (set) var error: Error? = nil

    /// Reactive streams.

    public private (set) var rx = Rx.empty

    // MARK: - Internal API

    private static let serialScheduler = SerialDispatchQueueScheduler.init(internalSerialQueueName: "nl.northernforest.locationtracker")
    private static let terminalCLErrorCodes: Set<Int> = [CLError.denied.rawValue]

    let _location = ReplaySubject<CLLocation>.create(bufferSize: 1)
    let _error = ReplaySubject<Error>.create(bufferSize: 1)
    let _paused = ReplaySubject<Bool>.create(bufferSize: 1)
    let _deferringAllowed = Variable<Bool>(false)

    let manager = CLLocationManager()
    var delegate: Delegate! = nil

    let backgroundUpdates: Bool

    private var subscribersCount = 0

    // MARK:

    init(backgroundUpdates: Bool) {
        self.backgroundUpdates = backgroundUpdates

        let rx_location = _location
            .observeOn(LocationTracker.serialScheduler)
            .do(
                onError: { _ in
                    self.stopTracking()
                },
                onSubscribe: { 
                    self.notifySubscribed()
                },
                onDispose: { 
                    self.notifyUnsubscribed()
                }
        )

        rx = Rx(
            location: rx_location,
            error: _error.asObservable(),
            paused: _paused.asObservable(),
            deferringAllowed: _deferringAllowed.asObservable()
        )

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

    /// Once `rx.location` observable is subscribed to, this is called.

    final func notifySubscribed() {
        assert(subscribersCount >= 0, "Subscribers count can not be negative")

        subscribersCount += 1

        if subscribersCount == 1 {
            startTracking()
        }
    }

    /// Once `rx.location` observable is disposed, this is called.

    final func notifyUnsubscribed() {
        subscribersCount -= 1

        assert(subscribersCount >= 0, "Subscribers count can not be negative")

        if subscribersCount == 0 {
            stopTracking()
        }
    }

    // MARK: - Delegate's API

    /// Respond to the updated location events.

    func handleUpdateLocations(_ locations: [CLLocation]) {
        locations.forEach {
            _location.onNext($0)
        }
    }

    /// Respond to the event of a change in the authorization status.

    func handleChangeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch (status, backgroundUpdates) {

        case (.restricted, _):
            handleError(Failure.locationServicesRestricted)

        case (.denied, _):
            handleError(Failure.locationServicesDenied)

        case (.authorizedWhenInUse, true):
            handleError(Failure.locationServicesAuthorizedWhenInUseOnly)

        default:
            break

        }
    }

    /// Respond to the event of an error.

    func handleError(_ error: Error) {
        self.error = error

        let ns_error = error as NSError

        if let error = error as? LocationTracker.Failure {
            _location.onError(error)
        } else if ns_error.domain == CLError.errorDomain && LocationTracker.terminalCLErrorCodes.contains(ns_error.code) {
            _location.onError(error)
        }

        
        _error.onNext(error)
    }

    /// Respond to the event of a pause in location updates.

    func handlePauseLocationUpdates() {
        _paused.onNext(true)
    }

    /// Respond to the event of resumed location updates.

    func handleResumeLocationUpdates() {
        _paused.onNext(false)
    }

    /// Respond to the event of deferred updates finish.

    func handleFinishDeferredUpdatesWithError(_ error: Error?) {
        // This will be only implemented by DeferredLocationUpdatesTracker
    }

    #if os(iOS)

    // MARK: - iOS specific

    /// Checks current authorization, requests one if needed, throws an error if none is given.

    func requestAuthorization() {
        switch (CLLocationManager.authorizationStatus(), backgroundUpdates) {

        case (.restricted, _):
            handleError(Failure.locationServicesRestricted)

        case (.denied, _):
            handleError(Failure.locationServicesDenied)

        case (.authorizedWhenInUse, true):
            handleError(Failure.locationServicesAuthorizedWhenInUseOnly)

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
        switch (CLLocationManager.authorizationStatus(), backgroundUpdates) {

        case (.restricted, _):
            handleError(Failure.locationServicesRestricted)

        case (.denied, _):
            handleError(Failure.locationServicesDenied)

        default:
            break
            
        }
    }

    #endif

}
