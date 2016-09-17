[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![RxSwift 3.0](https://img.shields.io/badge/RxSwift-3.0-A60079.svg?style=flat)](https://github.com/ReactiveX/RxSwift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# `RxLocationServices`

A framework of reactive wrapper classes to handle common location services related tasks:

- `LocationTracker`

## `LocationTracker`

Reactive wrapper for location tracking functionality provided by `CLLocationManager`.

### Use

The following elements might have to be included into your iOS app's `Info.plist` file for `LocationTracker` to work:

Key                                   | Description
---                                   | ---
`NSLocationWhenInUseUsageDescription` | Text for the prompt that requests user's permission to use location services while the app is running in foreground.
`NSLocationAlwaysUsageDescription`    | Prompt for the permission to use location services whenever the app is running (both background and foreground).
`UIBackgroundModes`                   | Include `location` value for the app to be able to receive location updates even when it is suspended.

Provided that all necessary keys from the above table are in your app's `Info.plist`, the rest will be taken care of by the framework.  It will request necessary authorization from the user at the right moment (that is, just before the location services have to be used), it will start GPS hardware when it's necessary, and stop it when it's not needed any more.

_Example_

````swift
let tracker = LocationTracker.standardTracker()
let timer = Observable<Int>.timer(60.0, scheduler: ConcurrentMainScheduler.instance)
let disposeBag = DisposeBag()

tracker.rx.location
    // Get the updates every 5+ seconds
    .distinctUntilChanged { (previous, current) -> Bool in
        current.timestamp.timeIntervalSince(previous.timestamp) < 5.0
    }
    // ... and only until the 1-minute timer fires
    .takeUntil(timer)
    .subscribe {
        print($0)
    }
    .addDisposableTo(disposeBag)
````

The code above creates a basic tracker and makes it produce location updates at 5-seconds intervals for one minute, after which this tracker will automatically stop GPS services.

Once the tracker is created, it's not yet doing any work and does not start GPS. It only does that at the moment of the first subscription.

Furthermore, at the moment the tracker detects that there are no subscribers, it stops GPS automatically.

If, after stopping the GPS, there would be another subscription on the tracker's `rx.location` outlet, the tracker would start GPS again and resume producing events.

### Types of trackers

There are three types of trackers available:

- Standard tracker
- Deferred location updates tracker
- Significant location change tracker

#### Standard tracker

Most usual kind of a location tracker.  You can specify desired accuracy, distance filter, and whether you want location updates to be delivered in background.

The standard location service is most appropriate for apps that deliver location-related information directly to the user but it may be used by other types of apps too.

_Example_

````swift
let standardTracker = LocationTracker.standardTracker(
    desiredAccuracy   : kCLLocationAccuracyHundredMeters,
    distanceFilter    : kCLDistanceFilterNone,
    backgroundUpdates : true
)
````

_See also_

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.startUpdatingLocation()](https://developer.apple.com/reference/corelocation/cllocationmanager/1423750-startupdatinglocation)

_Availability_

- iOS
- macOS

#### Deferred location updates tracker

This is a type of a tracker that allows GPS hardware to accumulate (batch) location updates internally until the distance/timeout thresholds are met, and only then deliver the whole batch to your app.

Use this tracker in situations where you want location data with GPS accuracy but do not need to process that data right away.  If your app is in the background and the system is able to optimize its power usage, the location manager tells the GPS hardware to store new locations internally until the specified distance or timeout conditions are met.  If your app is in the foreground, the location manager does not defer the deliver of events but does monitor for the specified criteria. If your app moves to the background before the criteria are met, the location manager may begin deferring the delivery of events.

_Example_

````swift
let deferringTracker = LocationTracker.deferredLocationUpdatesTracker(
    deferredDistance      : 500,
    deferredTimeout       : 60,
    activityType          : CLActivityType.fitness,
    accuracyForNavigation : false
)
````

_See also_

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.allowDeferredLocationUpdates(untilTraveled:timeout:)](https://developer.apple.com/reference/corelocation/cllocationmanager/1620547-allowdeferredlocationupdates)
- [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW8)
- [Answer: How to work with deferred location iOS 6?](http://stackoverflow.com/a/14509263/1542569)
- [Answer: ios deferred location updates fail to defer](http://stackoverflow.com/a/26345001/1542569)

_Availability_

- iOS

#### Significant location change tracker

A tracker that only reports significant changes in device's location.

The significant location change service is better suited for apps that want to get the user’s initial location and then only want to know when that location changes. This service requires the presence of cellular hardware and delivers events less frequently than the standard location services.

The significant location change service delivers events normally while an app is running in the foreground or background.  For a terminated iOS app, this service relaunches the app to deliver events.  Use of this service requires "Always" authorization from the user.

_Example_

````swift
let bigChangeTracker = LocationTracker.significantChangeTracker()
````

_See also_

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.startMonitoringSignificantLocationChanges()](https://developer.apple.com/reference/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati)
- [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW4)

_Availability_

- iOS
- macOS
