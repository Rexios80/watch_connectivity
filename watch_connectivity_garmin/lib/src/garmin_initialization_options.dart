import 'package:watch_connectivity_garmin/src/garmin_iq_connect_type.dart';

/// Initialization options for the Garmin SDK
class GarminInitializationOptions {
  /// The id of the companion application to communicate with
  final String applicationId;

  /// URL scheme of the iOS companion application
  final String urlScheme;

  /// Show UI to help the user resolve issues with Garmin Connect
  final bool autoUI;

  /// IQConnectType for connection type.  Android Only
  final GarminIQConnectType connectType;

  /// ADB Port for connection in tethered mode.  Android Only
  final int adbPort;

  /// Constructor
  GarminInitializationOptions({
    required this.applicationId,
    required this.urlScheme,
    this.autoUI = false,
    this.connectType = GarminIQConnectType.wireless,
    this.adbPort = 7381,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'applicationId': applicationId,
        'urlScheme': urlScheme,
        'autoUI': autoUI,
        'connectType': connectType.name,
        'adbPort': adbPort,
      };
}
