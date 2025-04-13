A wrapper for the ConnectIQ SDK to communicate with Garmin watches

## NOTE

By using this plugin, you accept the [ConnectIQ license agreement](https://developer.garmin.com/connect-iq/sdk/).

## Getting Started

iOS podfile changes:
```ruby
platform :ios, '13.0'
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

As of this moment you will have to develop your own Garmin watch app to send and receive messages, but here's a little start
```cpp
public function onMessageReceived(message) as Void {
  if (message != null && message.isValid()) {
    // this is a good message to use show this received data (the message is a map)
    var messageFromPhone = message.content();
    // and update our view for this message data
    WatchUi.requestUpdate();
  }
}

public function onTap(event as ClickEvent) as Void {
  var listener = new $.CommListener();
  var app = $.getApp();
  Communications.transmit({
    "clickX" => event.getCoordinates()[0],
    "clickY" => event.getCoordinates()[1],
    "content" => "Hello from the watch!",
  }, null, listener);
}
```

## Releasing (Android release build)
The app communicates with the Garmin classes via its namespace. So when released these can be minified
making them uncontactable. To prevent this from happening you will need to include the exclusions in your
`proguard-rules.pro` file as in the example:
```yaml
-keep class com.garmin.** { *; }
-keep class com.garmin.android.connectiq.** { *; }
-keep class com.garmin.android.apps.connectmobile.** { *; }
```

OR in your `build.gradle` you can set
```yaml
shrinkResources false
minifyEnabled false
```
* but this is not recommended as your code will be larger than it needs to be

## Unsupported Features

The following features are not supported by Garmin watches:
- Application context

Attempted usage of these features will throw an UnsupportedError

## Additional Information

See [watch_connectivity](https://pub.dev/packages/watch_connectivity) for more detailed documentation