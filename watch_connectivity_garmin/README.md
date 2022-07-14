A wrapper for the ConnectIQ SDK to communicate with Garmin watches

## Getting Started

iOS podfile changes:
```ruby
platform :ios, '13.0'

...

target 'Runner' do
  ...

  pod 'ConnectIQ', :git => 'https://github.com/Rexios80/ConnectIQ-pod', :tag => '0.2.0'
end
```

iOS Info.plist changes:
```xml
<key>CFBundleDisplayName</key>
<string>${PRODUCT_NAME}</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>{your.bundle.identifier}</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>{your-unique-string}</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>gcm-ciq</string>
</array>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Used to connect to wearable devices</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Used to connect to wearable devices</string>
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

## Usage

<!-- embedme readme/usage.dart -->
```dart
import 'dart:io';

import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';

void example() {
  final watch = WatchConnectivityGarmin();

  // Must be called before any other methods
  watch.initialize(
    GarminInitializationOptions(
      applicationId: 'your-application-id',
      urlScheme: 'your-url-scheme',
    ),
  );

  if (Platform.isIOS) {
    // On iOS, the Garmin Connect app must be launched to retrieve a list of
    // paired devices. This should be user-initiated, as the process will
    // suspend your app.
    watch.showDeviceSelection();
  }

  // Use as you would WatchConnectivity
}

```

## Unsupported Features

The following features are not supported by Garmin watches:
- Application context

Attempted usage of these features will throw an UnsupportedError

## Additional Information

See [watch_connectivity](https://pub.dev/packages/watch_connectivity) for more detailed documentation