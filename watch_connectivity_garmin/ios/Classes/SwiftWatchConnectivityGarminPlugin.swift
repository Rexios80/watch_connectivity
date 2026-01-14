import ConnectIQ
import Flutter
import UIKit

public class SwiftWatchConnectivityGarminPlugin: NSObject, FlutterPlugin, IQDeviceEventDelegate, IQAppMessageDelegate {
  private static let deviceIdsKey = "watch_connectivity_garmin/deviceIds"

  let connectIQ = ConnectIQ.sharedInstance()!
  let defaults = UserDefaults.standard
  let messageHandler = StreamHandler()
  let contextHandler = StreamHandler()
  var applicationId: String?
  var urlScheme: String?

  init(messageChannel: FlutterEventChannel, contextChannel: FlutterEventChannel) {
    messageChannel.setStreamHandler(messageHandler)
    contextChannel.setStreamHandler(contextHandler)

    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "watch_connectivity_garmin", binaryMessenger: registrar.messenger())
    let messageChannel = FlutterEventChannel(name: "watch_connectivity_garmin/messages", binaryMessenger: registrar.messenger())
    let contextChannel = FlutterEventChannel(name: "watch_connectivity_garmin/contexts", binaryMessenger: registrar.messenger())
    let instance = SwiftWatchConnectivityGarminPlugin(messageChannel: messageChannel, contextChannel: contextChannel)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // Getters
    case "isSupported":
      isSupported(result)
    case "isPaired":
      isPaired(result)
    case "isReachable":
      isReachable(result)
    // Methods
    case "initialize":
      initialize(call, result)
    case "showDeviceSelection":
      showDeviceSelection(result)
    case "sendMessage":
      sendMessage(call, result)
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
    guard url.scheme == urlScheme else {
      return false
    }

    let devices = connectIQ.parseDeviceSelectionResponse(from: url) as? [IQDevice]
    guard devices != nil else {
      return false
    }

    defaults.set(devices!.map { $0.uuid.uuidString }, forKey: Self.deviceIdsKey)
    registerForEvents()

    return true
  }

  private func getCachedDevices() -> [IQDevice] {
    return defaults.stringArray(forKey: Self.deviceIdsKey)?.map { IQDevice(id: UUID(uuidString: $0), modelName: "", friendlyName: "")! } ?? []
  }

  private func createApps() -> [IQApp] {
    return getCachedDevices().map { IQApp(uuid: UUID(uuidString: applicationId!)!, store: UUID(), device: $0) }
  }

  private func registerForEvents() {
    connectIQ.unregister(forAllAppMessages: self)
    connectIQ.unregister(forAllDeviceEvents: self)

    let apps = createApps()
    for app in apps {
      connectIQ.register(forDeviceEvents: app.device, delegate: self)
      connectIQ.register(forAppMessages: app, delegate: self)
    }
  }

  private func initialize(_ call: FlutterMethodCall, _ result: FlutterResult) {
    let args = call.arguments as! [String: Any]
    applicationId = args["applicationId"] as? String
    urlScheme = args["urlScheme"] as? String

    let autoUI = args["autoUI"] as? Bool ?? false

    connectIQ.initialize(withUrlScheme: urlScheme, uiOverrideDelegate: autoUI ? nil : IQUIOverrideDelegateStub())

    registerForEvents()

    result(nil)
  }

  private func showDeviceSelection(_ result: FlutterResult) {
    connectIQ.showDeviceSelection()
    result(nil)
  }

  private func isSupported(_ result: FlutterResult) {
    result(UIApplication.shared.canOpenURL(URL(string: "gcm-ciq://stub")!))
  }

  private func isPaired(_ result: FlutterResult) {
    result(getCachedDevices().isEmpty == false)
  }

  private func isReachable(_ result: @escaping FlutterResult) {
    Task { await isReachableAsync(result) }
  }

  private func isReachableAsync(_ result: FlutterResult) async {
    let apps = createApps()
    for app in apps {
      let installed = await withCheckedContinuation { continuation in
        connectIQ.getAppStatus(app) { status in
          continuation.resume(returning: status?.isInstalled == true)
        }
      }
      if installed {
        result(true)
        return
      }
    }

    result(false)
  }

  private func sendMessage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    Task { await sendMessageAsync(call, result) }
  }

  private func sendMessageAsync(_ call: FlutterMethodCall, _ result: FlutterResult) async {
    guard applicationId != nil else {
      result(FlutterError(code: "Not Initialized", message: nil, details: nil))
      return
    }

    let connectedApps = createApps().filter { connectIQ.getDeviceStatus($0.device) == .connected }

    guard !connectedApps.isEmpty else {
      result(FlutterError(code: "No connected devices", message: nil, details: nil))
      return
    }

    var errors = [String]()
    for app in connectedApps {
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        connectIQ.sendMessage(call.arguments, to: app, progress: { _, _ in }) { result in
          if result != .success {
            errors.append("\(result)")
          }
          continuation.resume()
        }
      }
    }

    if errors.isEmpty {
      result(nil)
    } else {
      result(FlutterError(code: "Error sending message", message: errors.joined(separator: ", "), details: nil))
    }
  }

  public func deviceStatusChanged(_ device: IQDevice!, status: IQDeviceStatus) {
    // Don't care
  }

  public func receivedMessage(_ message: Any!, from app: IQApp!) {
    messageHandler.success(message)
  }
}

class IQUIOverrideDelegateStub: NSObject, IQUIOverrideDelegate {}

class StreamHandler: NSObject, FlutterStreamHandler {
  private var sinks: [Int: FlutterEventSink] = [:]

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sinks[arguments as! Int] = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sinks.removeValue(forKey: arguments as! Int)
    return nil
  }
  
  func success(_ event: Any?) {
    for sink in sinks.values {
      sink(event)
    }
  }
}
