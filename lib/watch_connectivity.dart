import 'dart:async';

import 'package:flutter/services.dart';

/// Plugin to communcate with Apple Watch and Wear OS watches
class WatchConnectivity {
  static const MethodChannel _channel = MethodChannel('watch_connectivity');

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of messages received from the watch
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of context received from the watch
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  /// Create a new instance of the plugin
  WatchConnectivity() {
    _channel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveMessage':
        _messageStreamController.add(call.arguments as Map<String, dynamic>);
        break;
      case 'didReceiveApplicationContext':
        _contextStreamController.add(call.arguments as Map<String, dynamic>);
        break;
    }
  }

  /// If a watch is paired
  /// 
  /// On Android, this checks if either the Wear OS or Galaxy Wearable app is installed
  Future<bool> get isPaired async {
    final paired = await _channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// If the watch app is reachable
  Future<bool> get isReachable async {
    final reachable = await _channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// The most recent contextual data sent to the paired and active device
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext =
        await _channel.invokeMapMethod<String, dynamic>('applicationContext');
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received from a paired and
  /// active device
  /// 
  /// On Android this returns the same data as [applicationContext]
  Future<Map<String, dynamic>> get receivedApplicationContext async {
    final receivedApplicationContext = await _channel
        .invokeMapMethod<String, dynamic>('receivedApplicationContext');
    return receivedApplicationContext ?? {};
  }

  /// Send a message to the watch
  Future<void> sendMessage(Map<String, dynamic> message) {
    return _channel.invokeMethod('sendMessage', message);
  }

  /// Send a context to the watch
  Future<void> updateApplicationContext(
    Map<String, dynamic> context,
  ) {
    return _channel.invokeMethod('updateApplicationContext', context);
  }
}
