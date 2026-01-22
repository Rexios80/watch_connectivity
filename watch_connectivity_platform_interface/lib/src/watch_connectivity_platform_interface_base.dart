import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Interface to communicate with watch devices
///
/// Implementations are provided separately for each watch platform
///
/// See implementation overrides for platform-specific documentation
@immutable
abstract class WatchConnectivityBase {
  /// The channel for communicating with the plugin's native code
  @protected
  final MethodChannel methodChannel;

  /// The channel for receiving messages from the host platform
  @protected
  final EventChannel messageChannel;

  /// The channel for receiving contexts from the host platform
  @protected
  final EventChannel contextChannel;

  /// Stream of messages received
  late final messageStream = messageChannel
      .receiveBroadcastStream(identityHashCode(this))
      .map((e) => Map<String, dynamic>.from(e));

  /// Stream of contexts received
  late final contextStream = contextChannel
      .receiveBroadcastStream(identityHashCode(this))
      .map((e) => Map<String, dynamic>.from(e));

  /// Create an instance of [WatchConnectivityBase] for the given
  /// [pluginName]
  WatchConnectivityBase({required String pluginName})
      : methodChannel = MethodChannel('$pluginName/methods'),
        messageChannel = EventChannel('$pluginName/messages'),
        contextChannel = EventChannel('$pluginName/context');

  /// If watches are supported by the current platform
  Future<bool> get isSupported async {
    final supported = await methodChannel.invokeMethod<bool>('isSupported');
    return supported ?? false;
  }

  /// If a watch is paired
  Future<bool> get isPaired async {
    final paired = await methodChannel.invokeMethod<bool>('isPaired');
    return paired ?? false;
  }

  /// If the companion app is reachable
  Future<bool> get isReachable async {
    final reachable = await methodChannel.invokeMethod<bool>('isReachable');
    return reachable ?? false;
  }

  /// If the watch app is installed
  Future<bool> get isWatchAppInstalled async {
    final installed = await methodChannel.invokeMethod<bool>('isWatchAppInstalled');
    return installed ?? false;
  }

  /// The most recently sent contextual data
  Future<Map<String, dynamic>> get applicationContext async {
    final applicationContext = await methodChannel
        .invokeMapMethod<String, dynamic>('applicationContext');
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts async {
    final receivedApplicationContexts = await methodChannel
        .invokeListMethod<Map>('receivedApplicationContexts');
    return receivedApplicationContexts
            ?.map((e) => e.cast<String, dynamic>())
            .toList() ??
        [];
  }

  /// Send a message to all connected watches
  Future<void> sendMessage(Map<String, dynamic> message) {
    return methodChannel.invokeMethod('sendMessage', message);
  }

  /// Update the application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) {
    return methodChannel.invokeMethod('updateApplicationContext', context);
  }
}
