import Flutter
import UIKit
import WatchConnectivity

public class SwiftWatchConnectivityPlugin: NSObject, FlutterPlugin, WCSessionDelegate {
    let channel: FlutterMethodChannel
    let session: WCSession?
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        
        if WCSession.isSupported() {
            session = WCSession.default
        } else {
            session = nil
        }
        
        super.init()
        
        session?.delegate = self
        session?.activate()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "watch_connectivity", binaryMessenger: registrar.messenger())
        let instance = SwiftWatchConnectivityPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // Getters
        case "isPaired":
            result(session?.isPaired ?? false)
        case "isReachable":
            result(session?.isReachable ?? false)
        case "applicationContext":
            result(session?.applicationContext ?? [:])
        case "receivedApplicationContext":
            result(session?.receivedApplicationContext ?? [:])
        
        // Methods
        case "sendMessage":
            session?.sendMessage(call.arguments as! [String: Any], replyHandler: nil)
            result(nil)
        case "updateApplicationContext":
            do {
                try session?.updateApplicationContext(call.arguments as! [String: Any])
                result(nil)
            } catch {
                result(error)
            }
        
        // Not implemented
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    public func sessionDidDeactivate(_ session: WCSession) {}
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        channel.invokeMethod("didReceiveMessage", arguments: message)
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        channel.invokeMethod("didReceiveApplicationContext", arguments: applicationContext)
    }
}
