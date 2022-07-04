import ConnectIQ
import Flutter
import UIKit

public class SwiftWatchConnectivityGarminPlugin: NSObject, FlutterPlugin {
    private static let deviceIdsKey = "watch_connectivity_garmin/deviceIds"

    let channel: FlutterMethodChannel
    let connectIQ = ConnectIQ.sharedInstance()!
    let defaults = UserDefaults.standard
    var applicationId: String?
    var urlScheme: String?

    init(channel: FlutterMethodChannel) {
        self.channel = channel

        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "watch_connectivity_garmin", binaryMessenger: registrar.messenger())
        let instance = SwiftWatchConnectivityGarminPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // Getters
//        case "isSupported":
//            result(WCSession.isSupported())
//        case "isPaired":
//            result(session?.isPaired ?? false)
//        case "isReachable":
//            result(session?.isReachable ?? false)

        // Methods
        case "initialize":
            initialize(call, result)
        case "showDeviceSelection":
            showDeviceSelection(result)
//        case "sendMessage":
//            session?.sendMessage(call.arguments as! [String: Any], replyHandler: nil)
//            result(nil)

        // Not implemented
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard url.scheme == urlScheme, options[.sourceApplication] as? String == IQGCMBundle else {
            return false
        }

        let devices = connectIQ.parseDeviceSelectionResponse(from: url) as? [IQDevice]
        guard devices != nil else {
            return true
        }

        defaults.set(devices!.map { $0.uuid }, forKey: Self.deviceIdsKey)

        return true
    }

    private func initialize(_ call: FlutterMethodCall, _ result: FlutterResult) {
        let args = call.arguments as! [String: Any]
        applicationId = args["applicationId"] as? String
        urlScheme = args["urlScheme"] as? String
        
        let autoUI = args["autoUI"] as? Bool ?? false

        connectIQ.initialize(withUrlScheme: urlScheme, uiOverrideDelegate: autoUI ? nil : IQUIOverrideDelegateStub())
        result(nil)
    }

    private func showDeviceSelection(_ result: FlutterResult) {
        connectIQ.showDeviceSelection()
        result(nil)
    }
}

class IQUIOverrideDelegateStub: NSObject, IQUIOverrideDelegate {}
