Platform interface for communicating with wearable watch devices

## Plugins
The following plugins implement this interface:

| Plugin                                                                          | Description                               |
| ------------------------------------------------------------------------------- | ----------------------------------------- |
| [watch_connectivity](https://pub.dev/packages/watch_connectivity)               | Implementation for WearOS and Apple Watch |
| [watch_connectivity_garmin](https://pub.dev/packages/watch_connectivity_garmin) | Implementation for Garmin watches         |

## Contributing
This is not a typical platform interface. All implementations are standalone plugins that implement their own native code. This platform interface simply standardizes watch communication across all watch platforms.

New implementations should include the following:
- An implementation of `WatchConnectivityBase` with the following:
  - Implementation specific documentation if functionality differs significantly from standard behavior
  - Any required implementation specific methods (ex: the `initialize` mehtod in the Garmin implementation)
- An export for the platform interface so that `WatchConnectivityBase` can be used for typing


Any new features/methods that have possible equivalents in other implementations should be investigated and possibly added to the platform interface