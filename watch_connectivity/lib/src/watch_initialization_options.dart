/// Container for specialized initialization options for the WatchConnectivity service
abstract class WatchInitializationOptions {
  /// Method to serialize the options to send to native code
  Map<String, dynamic> toJson();
}
