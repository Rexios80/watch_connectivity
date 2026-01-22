import Flutter
import UIKit
import WatchConnectivity

public class SwiftWatchConnectivityPlugin: NSObject, FlutterPlugin, WCSessionDelegate {
  let messageHandler = StreamHandler()
  let contextHandler = StreamHandler()
  let session: WCSession?
    
  init(messageChannel: FlutterEventChannel, contextChannel: FlutterEventChannel) {
    messageChannel.setStreamHandler(messageHandler)
    contextChannel.setStreamHandler(contextHandler)

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
    let methodChannel = FlutterMethodChannel(name: "watch_connectivity/methods", binaryMessenger: registrar.messenger())
    let messageChannel = FlutterEventChannel(name: "watch_connectivity/messages", binaryMessenger: registrar.messenger())
    let contextChannel = FlutterEventChannel(name: "watch_connectivity/context", binaryMessenger: registrar.messenger())
    let instance = SwiftWatchConnectivityPlugin(messageChannel: messageChannel, contextChannel: contextChannel)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // Getters
    case "isSupported":
      result(WCSession.isSupported())
    case "isPaired":
      result(session?.isPaired ?? false)
    case "isReachable":
      result(session?.isReachable ?? false)
    case "isWatchAppInstalled":
      result(session?.isWatchAppInstalled ?? false)
    case "applicationContext":
      result(session?.applicationContext ?? [:])
    case "receivedApplicationContexts":
      result([session?.receivedApplicationContext ?? [:]])
    // Methods
    case "sendMessage":
      session?.sendMessage(call.arguments as! [String: Any], replyHandler: nil)
      result(nil)
    case "updateApplicationContext":
      do {
        try session?.updateApplicationContext(call.arguments as! [String: Any])
        result(nil)
      } catch {
        result(FlutterError(code: "Error updating application context", message: error.localizedDescription, details: nil))
      }
    // Not implemented
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
  public func sessionDidBecomeInactive(_ session: WCSession) {}
    
  public func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }
    
  public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async {
      self.messageHandler.success(message)
    }
  }
    
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    DispatchQueue.main.async {
      self.contextHandler.success(applicationContext)
    }
  }
}

class StreamHandler: NSObject, FlutterStreamHandler {
  private var sinks: [Int: FlutterEventSink] = [:]

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sinks[arguments as! Int] = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    guard let id = arguments as? Int else { return nil }
    sinks.removeValue(forKey: id)
    return nil
  }
  
  func success(_ event: Any?) {
    for sink in sinks.values {
      sink(event)
    }
  }
}
