import 'package:watch_connectivity_platform_interface/watch_connectivity_platform_interface.dart';

/// Plugin to communicate with Apple Watch and WearOS devices
class WatchConnectivity extends WatchConnectivityBase {
  /// Constructor
  WatchConnectivity() : super(pluginName: 'watch_connectivity');

  /// WearOS: Always true
  @override
  Future<bool> get isSupported => super.isSupported;

  /// WearOS: If either the Wear OS or Galaxy Wearable app is installed
  @override
  Future<bool> get isPaired => super.isPaired;

  /// WearOS: If any nodes are connected
  @override
  Future<bool> get isReachable => super.isReachable;

  /// Apple Watch: This will only ever contain one map
  ///
  /// WearOS: This will contain one map for every node that has sent a context
  @override
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts =>
      super.receivedApplicationContexts;

  /// Apple Watch: Start the watch app with a workout session. Currently there
  /// is no way to configure the session from the phone side.
  ///
  /// WearOS: Does nothing
  @override
  Future<void> startWatchApp() => super.startWatchApp();
}
