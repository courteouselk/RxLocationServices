# RxLocationServices

A set of reactive wrapper classes to handle common location services related tasks.

## `LocationTracker`

Reactive wrapper for location tracking functionality of `CLLocationManager`.

> The following elements might have to be included into your iOS app's `info.plist` file for `LocationTracker` API to work as expected:
>
> - `NSLocationWhenInUseUsageDescription` with the user prompt text for requesting a permission to use location services when the app is in use.
> - `NSLocationAlwaysUsageDescription` with the user prompt text for requesting a permission to use location services whenever the app is running.
> - `UIBackgroundModes` including the `location` value to receive location updates when the app is suspended.

There are three types of trackers available:

- Standard tracker
- Deferred location updates tracker
- Significant location change tracker

## Standard tracker

````swift

````

## Deferred location updates tracker

````swift

````

## Significant location change tracker

