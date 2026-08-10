import Flutter
import WatchConnectivity

public class WatchConnectivityPlugin: NSObject, FlutterPlugin, WCSessionDelegate {
    private let channel: FlutterMethodChannel
    private let session: WCSession?

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
        let instance = WatchConnectivityPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
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
        case "sendMessage":
            guard let message = call.arguments as? [String: Any] else {
                result(FlutterError(code: "invalid_arguments", message: "sendMessage expects a dictionary.", details: nil))
                return
            }
            guard let session else {
                result(FlutterError(code: "session_unavailable", message: "WatchConnectivity is not available on this device.", details: nil))
                return
            }
            var didComplete = false
            func completeOnce(_ value: Any?) {
                DispatchQueue.main.async {
                    guard !didComplete else {
                        return
                    }
                    didComplete = true
                    result(value)
                }
            }
            // Sent with a reply handler, so the future completes on real
            // delivery rather than optimistically — WCSession has no
            // "delivered" callback for the reply-less form.
            //
            // The cost is that this only reaches a counterpart implementing
            // `session(_:didReceiveMessage:replyHandler:)`: WCSession routes
            // by which form the *sender* used, and a counterpart implementing
            // only `session(_:didReceiveMessage:)` fails the send with
            // `WCErrorCodeDeliveryFailed`. Callers must therefore treat this
            // as best-effort and still push the state through
            // `updateApplicationContext`, which reaches a counterpart of
            // either shape and survives it not running.
            session.sendMessage(
                message,
                replyHandler: { _ in
                    completeOnce(nil)
                },
                errorHandler: { error in
                    completeOnce(FlutterError(code: "message_send_failed", message: error.localizedDescription, details: nil))
                }
            )
        case "updateApplicationContext":
            guard let context = call.arguments as? [String: Any] else {
                result(FlutterError(code: "invalid_arguments", message: "updateApplicationContext expects a dictionary.", details: nil))
                return
            }
            guard let session else {
                result(FlutterError(code: "session_unavailable", message: "WatchConnectivity is not available on this device.", details: nil))
                return
            }
            do {
                try session.updateApplicationContext(context)
                result(nil)
            } catch {
                result(FlutterError(code: "application_context_update_failed", message: error.localizedDescription, details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        var arguments: [String: Any] = [
            "activationState": activationState.rawValue,
            "isActivated": activationState == .activated,
        ]

        if let error {
            NSLog("WatchConnectivity activation failed: %@", error.localizedDescription)
            arguments["error"] = [
                "code": "activation_failed",
                "message": error.localizedDescription,
            ]
        }

        invokeOnMain("activationDidComplete", arguments)
    }

    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        // A paired-watch switch deactivates the session; without reactivating,
        // every later send fails silently.
        session.activate()
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        invokeOnMain("didReceiveMessage", message)
    }

    /// The counterpart wants an answer, so Dart gets to produce one.
    ///
    /// Without this, a counterpart calling
    /// `sendMessage(_:replyHandler:errorHandler:)` cannot reach this app at
    /// all — WCSession refuses to deliver to a delegate that only implements
    /// the reply-less variant. That is what a watch app does when it asks the
    /// phone to re-send its configuration.
    public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("didReceiveMessageWithReply", arguments: message) { reply in
                // A Dart handler that threw, or none registered at all, still
                // has to answer something: leaving `replyHandler` uncalled
                // makes the counterpart's send time out.
                replyHandler(reply as? [String: Any] ?? [:])
            }
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        invokeOnMain("didReceiveApplicationContext", applicationContext)
    }

    /// WCSession delivers its callbacks on a background queue, while a
    /// `FlutterMethodChannel` may only be touched from the platform thread.
    private func invokeOnMain(_ method: String, _ arguments: Any?) {
        DispatchQueue.main.async {
            self.channel.invokeMethod(method, arguments: arguments)
        }
    }
}
