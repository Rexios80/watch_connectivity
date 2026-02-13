import Flutter
import UIKit
import WatchConnectivity

public class SwiftWatchConnectivityPlugin: NSObject, FlutterPlugin {
  static let delegate = SessionDelegate()
  static let messageHandler = StreamHandler()
  static let contextHandler = StreamHandler()
  static var session: WCSession?

  init(messageChannel: FlutterEventChannel, contextChannel: FlutterEventChannel) {
    messageChannel.setStreamHandler(Self.messageHandler)
    contextChannel.setStreamHandler(Self.contextHandler)

    if Self.session == nil, WCSession.isSupported() {
      Self.session = WCSession.default
      Self.session?.delegate = Self.delegate
      Self.session?.activate()
    }

    super.init()
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
      result(Self.session?.isPaired ?? false)
    case "isReachable":
      result(Self.session?.isReachable ?? false)
    case "applicationContext":
      result(Self.session?.applicationContext ?? [:])
    case "receivedApplicationContexts":
      result([Self.session?.receivedApplicationContext ?? [:]])
    // Methods
    case "sendMessage":
      Self.session?.sendMessage(call.arguments as! [String: Any], replyHandler: nil)
      result(nil)
    case "updateApplicationContext":
      do {
        try Self.session?.updateApplicationContext(call.arguments as! [String: Any])
        result(nil)
      } catch {
        result(FlutterError(code: "Error updating application context", message: error.localizedDescription, details: nil))
      }
    // Not implemented
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class SessionDelegate: NSObject, WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async {
      SwiftWatchConnectivityPlugin.messageHandler.success(message)
    }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    DispatchQueue.main.async {
      SwiftWatchConnectivityPlugin.contextHandler.success(applicationContext)
    }
  }
}

class StreamHandler: NSObject, FlutterStreamHandler {
  private var sinks: [String: FlutterEventSink] = [:]

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sinks[arguments as! String] = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    guard let id = arguments as? String else { return nil }
    sinks.removeValue(forKey: id)
    return nil
  }

  func success(_ event: Any?) {
    for sink in sinks.values {
      sink(event)
    }
  }
}
