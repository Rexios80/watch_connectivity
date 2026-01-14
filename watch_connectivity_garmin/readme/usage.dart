import 'dart:io';

import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';

void example() {
  final watch = WatchConnectivityGarmin();

  // Must be called before any other methods
  watch.initialize(
    const GarminInitializationOptions(
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
