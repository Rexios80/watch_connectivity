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
    case "isSupported":
      result(WCSession.isSupported())
    case "isPaired":
      result(session?.isPaired ?? false)
    case "isReachable":
      result(session?.isReachable ?? false)
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
    
  public func sessionDidDeactivate(_ session: WCSession) {}
    
  public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async {
      self.channel.invokeMethod("didReceiveMessage", arguments: message)
    }
  }
    
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    DispatchQueue.main.async {
      self.channel.invokeMethod("didReceiveApplicationContext", arguments: applicationContext)
    }
  }
    
  public func session(_ session: WCSession, didReceive file: WCSessionFile) {
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("SwiftWatchConnectivityPlugin: Error finding documents directory.")
      return
    }
    let newFileURL = documentsDirectory.appendingPathComponent(file.fileURL.lastPathComponent)
    DispatchQueue.global().async {
      do {
        if fileManager.fileExists(atPath: newFileURL.path) {
          try fileManager.removeItem(at: newFileURL)
        }
        try fileManager.moveItem(at: file.fileURL, to: newFileURL)
        print("SwiftWatchConnectivityPlugin: Moved file to \(newFileURL.path)")
        DispatchQueue.main.async {
          self.channel.invokeMethod("didReceiveTransferFile", arguments: ["fileURL": newFileURL.absoluteString])
        }
      } catch {
        print("SwiftWatchConnectivityPlugin: Error moving file: \(error.localizedDescription)")
      }
    }
  }
}
