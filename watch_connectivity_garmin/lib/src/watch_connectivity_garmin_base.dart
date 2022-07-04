import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';
import 'package:watch_connectivity_platform_interface/watch_connectivity_platform_interface.dart';

/// Plugin to communicate with Garmin watches
class WatchConnectivityGarmin extends WatchConnectivityBase {
  @override
  Stream<Map<String, dynamic>> get contextStream =>
      throw UnsupportedError('Unsupported by Garmin watches');

  /// Constructor
  WatchConnectivityGarmin() : super(pluginName: 'watch_connectivity_garmin');

  /// Initialize the platform SDK
  Future<void> initialize(GarminInitializationOptions options) {
    return channel.invokeMethod('initialize', options.toJson());
  }

  /// If the Garmin Connect app is installed
  @override
  Future<bool> get isSupported => super.isSupported;

  /// If the companion app is installed
  @override
  Future<bool> get isReachable => super.isReachable;

  @override
  Future<Map<String, dynamic>> get applicationContext =>
      throw UnsupportedError('Unsupported by Garmin watches');

  @override
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts =>
      throw UnsupportedError('Unsupported by Garmin watches');

  @override
  Future<void> updateApplicationContext(Map<String, dynamic> context) =>
      throw UnsupportedError('Unsupported by Garmin watches');
}
