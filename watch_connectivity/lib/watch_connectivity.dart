import 'dart:async';

import 'package:flutter/services.dart';

/// Plugin to communcate with Apple Watch and Wear OS devices
class WatchConnectivity {
  late final MethodChannel _channel;

  /// The type of watch this plugin instance communicates with
  final WatchType type;

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of messages received
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  ///
  /// Unsupported watch types:
  /// - [WatchType.garmin]
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  /// Create a new instance of the plugin
  WatchConnectivity({this.type = WatchType.base}) {
    switch (type) {
      case WatchType.base:
        _channel = const MethodChannel('watch_connectivity');
        break;
      case WatchType.garmin:
        _channel = const MethodChannel('watch_connectivity_garmin');
        break;
    }

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

  /// Apple Watch: WCSession.isSupported()
  ///
  /// WearOS: Always true
  /// 
  /// Garmin: If the Garmin Connect app is installed
  Future<bool> get isSupported async {
    final supported = await _channel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  /// Apple Watch, Garmin: If a watch is paired
  ///
  /// WearOS: If either the Wear OS or Galaxy Wearable app is installed
  Future<bool> get isPaired async {
    final paired = await _channel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// Apple Watch: If the companion app is reachable
  ///
  /// WearOS: If any nodes are connected
  /// 
  /// Garmin: If the companion app is installed
  Future<bool> get isReachable async {
    final reachable = await _channel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// The most recently sent contextual data
  ///
  /// Unsupported watch types:
  /// - [WatchType.garmin]
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext =
        await _channel.invokeMapMethod<String, dynamic>('applicationContext');
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  ///
  /// Apple Watch: This will only ever contain one map
  ///
  /// WearOS: This will contain one map for every node that has sent a context
  ///
  /// Unsupported watch types:
  /// - [WatchType.garmin]
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
  ///
  /// Unsupported watch types:
  /// - [WatchType.garmin]
  Future<void> updateApplicationContext(
    Map<String, dynamic> context,
  ) {
    return _channel.invokeMethod('updateApplicationContext', context);
  }
}

/// Enum of watch types this plugin supports
enum WatchType {
  /// WearOS and Apple Watch
  base,

  /// Garmin watch
  ///
  /// Requires the `watch_connectivity_garmin` plugin
  garmin,
}
