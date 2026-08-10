import 'dart:async';

import 'package:flutter/services.dart';

/// Answers a message the counterpart sent expecting a reply.
///
/// Returning an empty map is a valid "nothing to say"; the counterpart's send
/// fails if nobody answers at all, so the plugin always replies with something.
typedef WatchMessageResponder =
    Future<Map<String, dynamic>> Function(Map<String, dynamic> message);

/// Plugin to communicate with Apple Watch and WearOS devices
class WatchConnectivity {
  /// The channel for communicating with the plugin's native code
  final MethodChannel channel;

  WatchMessageResponder? _messageResponder;

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _activationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  var _isDisposed = false;

  /// Stream of messages received
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  /// Stream of WatchConnectivity activation updates
  Stream<Map<String, dynamic>> get activationStream =>
      _activationStreamController.stream;

  /// Create an instance of [WatchConnectivity]
  WatchConnectivity() : channel = MethodChannel('watch_connectivity') {
    channel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    if (_isDisposed) {
      return;
    }

    switch (call.method) {
      case 'didReceiveMessage':
        _messageStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'didReceiveMessageWithReply':
        final message = Map<String, dynamic>.from(call.arguments);
        _messageStreamController.add(message);
        final responder = _messageResponder;
        if (responder == null) return <String, dynamic>{};
        return await responder(message);
      case 'didReceiveApplicationContext':
        _contextStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'activationDidComplete':
        _activationStreamController.add(
          Map<String, dynamic>.from(call.arguments),
        );
        break;
      default:
        throw UnimplementedError('${call.method} not implemented');
    }
  }

  /// If watches are supported by the current platform
  Future<bool> get isSupported async {
    final supported = await channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  /// If a watch is paired
  Future<bool> get isPaired async {
    final paired = await channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// If the companion app is reachable
  Future<bool> get isReachable async {
    final reachable = await channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// The most recently sent contextual data
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext = await channel.invokeMapMethod<String, dynamic>(
      'applicationContext',
    );
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts async {
    final receivedApplicationContexts = await channel.invokeListMethod<Map>(
      'receivedApplicationContexts',
    );
    return receivedApplicationContexts
            ?.map((e) => e.cast<String, dynamic>())
            .toList() ??
        [];
  }

  /// Send a message to all connected watches.
  ///
  /// Best-effort and only for a counterpart that is running right now: it
  /// throws if the counterpart is unreachable, and also if it is reachable but
  /// implements only the reply-less receive callback (WCSession routes by the
  /// form the sender used, and this sends the reply-carrying one so delivery
  /// can be confirmed). Pair it with [updateApplicationContext], which reaches
  /// a counterpart of either shape and survives it not running.
  Future<void> sendMessage(Map<String, dynamic> message) {
    return channel.invokeMethod('sendMessage', message);
  }

  /// Answer messages the counterpart sends expecting a reply.
  ///
  /// Only one responder is active; setting a new one replaces it. Messages are
  /// published on [messageStream] either way, so a listener that does not need
  /// to answer needs nothing here.
  set messageResponder(WatchMessageResponder? responder) {
    _messageResponder = responder;
  }

  /// Update the application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) {
    return channel.invokeMethod('updateApplicationContext', context);
  }

  /// Start the watch app
  Future<void> startWatchApp() {
    return channel.invokeMethod('startWatchApp');
  }

  /// Release stream controllers and unregister platform callbacks.
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _messageResponder = null;
    channel.setMethodCallHandler(null);
    _messageStreamController.close();
    _contextStreamController.close();
    _activationStreamController.close();
  }
}
