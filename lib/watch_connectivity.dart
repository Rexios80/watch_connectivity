import 'dart:async';

import 'package:flutter/services.dart';

/// Plugin to communcate with Apple Watch and Wear OS devices
class WatchConnectivity {
  static const MethodChannel _channel = MethodChannel('watch_connectivity');

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of messages received
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  /// Create a new instance of the plugin
  WatchConnectivity() {
    _channel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveMessage':
        _messageStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'didReceiveApplicationContext':
        _contextStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      default:
        throw UnimplementedError('${call.method} not implemented');
    }
  }

  /// iOS: WCSession.isSupported()
  ///
  /// Android: Always true
  Future<bool> get isSupported async {
    final supported = await _channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  /// iOS: If a watch is paired
  ///
  /// Android: If either the Wear OS or Galaxy Wearable app is installed
  Future<bool> get isPaired async {
    final paired = await _channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// iOS: If the companion app is reachable
  ///
  /// Android: If any nodes are connected
  Future<bool> get isReachable async {
    final reachable = await _channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// The most recently sent contextual data
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext =
        await _channel.invokeMapMethod<String, dynamic>('applicationContext');
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  ///
  /// iOS: This will only ever contain one map
  ///
  /// Android: This will contain one map for every node that has sent a context
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
        await _channel.invokeListMethod('receivedApplicationContexts');
    final transformedContexts = receivedApplicationContexts
        ?.map((e) => Map<String, dynamic>.from(e))
        .toList();
    return transformedContexts ?? [];
  }

  /// Send a message to all nodes
  Future<void> sendMessage(Map<String, dynamic> message) {
    return _channel.invokeMethod('sendMessage', message);
  }

  /// Update the application context
  Future<void> updateApplicationContext(
    Map<String, dynamic> context,
  ) {
    return _channel.invokeMethod('updateApplicationContext', context);
  }
}
