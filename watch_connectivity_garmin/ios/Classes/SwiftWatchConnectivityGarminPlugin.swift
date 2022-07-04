import Flutter
import UIKit
import ConnectIQ

public class SwiftWatchConnectivityGarminPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "watch_connectivity_garmin", binaryMessenger: registrar.messenger())
    let instance = SwiftWatchConnectivityGarminPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
      
      ConnectIQ.sharedInstance()
  }
}
