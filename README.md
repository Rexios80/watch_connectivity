A wrapper for WatchConnectivity on iOS and Wearable APIs on Android

## Features

Communication directions:
- Android phone to Wear OS
- Wear OS to Android phone
- iPhone to Apple Watch

Communication methods:
- Send messages
- Receive messages
- Update context
- Receive context

Other features:
- Tell if a watch is paired
  - On Android it is not possible to check if a watch is paired. This plugin checks if either the Wear OS or Galaxy Wearable apps are installed.
- Tell if the counterpart is reachable
  - On Android it is not possible to tell if the counterpart app is reachable. This plugin checks if any nodes are connected.

## Usage

<!-- embedme readme/usage.dart -->
```dart
import 'package:watch_connectivity/watch_connectivity.dart';

void example() {
  final watch = WatchConnectivity();

  // Get the state of device connectivity
  watch.isPaired;
  watch.isReachable;

  // Get existing data
  watch.applicationContext;
  watch.receivedApplicationContexts;

  // Send data
  watch.sendMessage({'data': 'Hello'});
  watch.updateApplicationContext({'data': 0});

  // Listen for updates
  watch.messageStream.listen(null);
  watch.contextStream.listen(null);
}

```
