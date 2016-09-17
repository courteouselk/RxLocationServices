# `RxLocationServices`

A framework of reactive wrapper classes to handle common location services related tasks:

- `LocationTracker`

## `LocationTracker`

Reactive wrapper for location tracking functionality provided by `CLLocationManager`.

The following elements might have to be included into your iOS app's `Info.plist` file for `LocationTracker` to work:

Key                                   | Description
---                                   | ---
`NSLocationWhenInUseUsageDescription` | Text for the prompt that requests user's permission to use location services while the app is running in foreground.
`NSLocationAlwaysUsageDescription`    | Prompt for the permission to use location services whenever the app is running (both background and foreground).
`UIBackgroundModes`                   | Include `location` value for the app to be able to receive location updates even when it is suspended.

Provided that all necessary keys from the above table are in your app's `Info.plist`, the rest will be taken care of by the framework.  It will request necessary authorization from the user at the right moment (that is, just before the location services have to be used), will start GPS hardware when it's necessary, and stop it when it's not needed any more.

There are three types of trackers available:

- Standard tracker
- Deferred location updates tracker
- Significant location change tracker

### Standard tracker

Most usual kind of a location tracker.  You can specify desired accuracy, distance filter, and whether you want location updates to be delivered in background.

The standard location service is most appropriate for apps that deliver location-related information directly to the user but it may be used by other types of apps too.

**Example**

````swift
let standardTracker = LocationTracker.standardTracker(
    desiredAccuracy   : kCLLocationAccuracyHundredMeters,
    distanceFilter    : kCLDistanceFilterNone,
    backgroundUpdates : true
)
````

**See also**

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.startUpdatingLocation()](https://developer.apple.com/reference/corelocation/cllocationmanager/1423750-startupdatinglocation)

**Availability**

- iOS
- macOS

### Deferred location updates tracker

This is a type of a tracker that allows GPS hardware to accumulate (batch) location updates internally until the distance/timeout thresholds are met, and only then deliver the whole batch to your app.

Use this tracker in situations where you want location data with GPS accuracy but do not need to process that data right away.  If your app is in the background and the system is able to optimize its power usage, the location manager tells the GPS hardware to store new locations internally until the specified distance or timeout conditions are met.  If your app is in the foreground, the location manager does not defer the deliver of events but does monitor for the specified criteria. If your app moves to the background before the criteria are met, the location manager may begin deferring the delivery of events.

**Example**

````swift
let deferringTracker = LocationTracker.deferredLocationUpdatesTracker(
    deferredDistance      : 500,
    deferredTimeout       : 60,
    activityType          : CLActivityType.fitness,
    accuracyForNavigation : false
)
````

**See also**

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.allowDeferredLocationUpdates(untilTraveled:timeout:)](https://developer.apple.com/reference/corelocation/cllocationmanager/1620547-allowdeferredlocationupdates)
- [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW8)
- [Answer: How to work with deferred location iOS 6?](http://stackoverflow.com/a/14509263/1542569)
- [Answer: ios deferred location updates fail to defer](http://stackoverflow.com/a/26345001/1542569)

**Availability**

- iOS

### Significant location change tracker

A tracker that only reports significant changes in device's location.

The significant location change service is better suited for apps that want to get the user’s initial location and then only want to know when that location changes. This service requires the presence of cellular hardware and delivers events less frequently than the standard location services.

The significant location change service delivers events normally while an app is running in the foreground or background.  For a terminated iOS app, this service relaunches the app to deliver events.  Use of this service requires "Always" authorization from the user.

**Example**

````swift
let bigChangeTracker = LocationTracker.significantChangeTracker()
````

**See also**

- [CLLocationManager](https://developer.apple.com/reference/corelocation/cllocationmanager#overview)
- [CLLocationManager.startMonitoringSignificantLocationChanges()](https://developer.apple.com/reference/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati)
- [Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html#//apple_ref/doc/uid/TP40015243-CH24-SW4)

**Availability**

- iOS
- macOS

### Use

Once the tracker is created, it's not yet doing any work.  In order to get the location data from it you need to subscribe to its reactive outlet.

**Example**

````swift
let disposeBag = DisposeBag()
let timer = Observable<Int>.timer(60.0, scheduler: ConcurrentMainScheduler.instance)
let tracker = LocationTracker.standardTracker()

tracker.rx.location
    // Get the updates every 5+ seconds
    .distinctUntilChanged { (previous, current) -> Bool in
        current.timestamp.timeIntervalSince(previous.timestamp) < 5.0
    }
    // ... and only until the timer expires after 1 minute
    .takeUntil(timer)
    .subscribe {
        print($0)
    }
    .addDisposableTo(disposeBag)
````

The code above will create a basic tracker and make it produce location updates at 5 seconds intervals for 1 minute, after which this tracker will automatically stop GPS services (just at the moment the only subscriber is disposed of).

If it were to have another subscription afterwards, then it would start GPS again and resume `rx.location` stream.
