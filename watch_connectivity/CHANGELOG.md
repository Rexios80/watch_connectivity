## 0.2.4

- Android compileSdkVersion 36

## 0.2.3

- Adds the new Wear OS companion app identifier (by [@J-shw](https://github.com/J-shw) in [#34](https://github.com/Rexios80/watch_connectivity/pull/34))

## 0.2.2

- Reactivate the `WatchConnectivity` session in `sessionDidDeactivate` (by [@yoneryota](https://github.com/yoneryota) in [#32](https://github.com/Rexios80/watch_connectivity/pull/32))

## 0.2.1+1

- Updates README

## 0.2.1

- Fixes resource linking issue caused by too low compile SDK
- Updates `play-services-wearable` to version `19.0.0`
- Invokes iOS platform channel methods on main thread

## 0.2.0

- BREAKING: Removes `startWatchApp` method due to the dependency on `HealthKit` causing issues with app review
- The `startWatchApp` functionality has been moved to the `workout` plugin

## 0.1.6

- Adds namespace to `build.gradle` to support Gradle 8

## 0.1.5

- Documentation updates

## 0.1.4+1

- Documentation updates

## 0.1.4

- Fixes Android build issue

## 0.1.3

- `WatchConnectivity` now implements `WatchConnectivityBase` from `watch_connectivity_platform_interface`

## 0.1.2

- Fixed build issue on Android

## 0.1.1

- Added isSupported

## 0.1.0

- Initial release
