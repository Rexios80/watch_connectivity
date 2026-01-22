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

  /// Apple Watch: If the watch app is installed
  ///
  /// WearOS: If any connected nodes exist (best-effort check)
  @override
  Future<bool> get isWatchAppInstalled => super.isWatchAppInstalled;

  /// Apple Watch: This will only ever contain one map
  ///
  /// WearOS: This will contain one map for every node that has sent a context
  @override
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts =>
      super.receivedApplicationContexts;
}
