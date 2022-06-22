/// Initialization options for the Garmin SDK
class GarminInitializationOptions {
  /// The id of the companion application to communicate with
  final String applicationId;

  /// Show UI to help the user resolve issues with Garmin Connect
  final bool autoUI;

  /// Constructor
  GarminInitializationOptions({
    required this.applicationId,
    this.autoUI = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'applicationId': applicationId,
        'autoUI': autoUI,
      };
}
