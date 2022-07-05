import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';

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

  /// Launches Garmin Connect Mobile for the purpose of retrieving a list of
  /// ConnectIQ-compatible devices. Note that by launching GCM, this method
  /// causes the companion app to go into the background, possibly resulting in
  /// the app being suspended. The companion app should expect to be suspended
  /// when calling this method.
  ///
  /// Returned devices are cached natively in UserDefaults
  ///
  /// iOS only
  Future<void> showDeviceSelection() {
    return channel.invokeMethod('showDeviceSelection');
  }

  /// If the Garmin Connect app is installed
  @override
  Future<bool> get isSupported => super.isSupported;

  /// If the companion app is installed on any accessible watches
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
