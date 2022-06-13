import 'package:watch_connectivity/src/watch_connectivity_base.dart';

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
