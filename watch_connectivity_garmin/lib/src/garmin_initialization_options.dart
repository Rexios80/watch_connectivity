import 'package:watch_connectivity/watch_connectivity.dart';

/// Initialization options for the Garmin SDK
class GarminInitializationOptions extends WatchInitializationOptions {
  /// The id of the companion application to communicate with
  final String applicationId;

  /// Show UI to help the user resolve issues with Garmin Connect
  final bool autoUI;

  /// Constructor
  GarminInitializationOptions({
    required this.applicationId,
    this.autoUI = false,
  });

  @override
  Map<String, dynamic> toJson() => {
        'applicationId': applicationId,
        'autoUI': autoUI,
      };
}
