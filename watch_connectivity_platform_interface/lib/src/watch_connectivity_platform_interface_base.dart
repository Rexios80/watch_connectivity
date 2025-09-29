import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interface to communicate with watch devices
///
/// Implementations are provided separately for each watch platform
///
/// See implementation overrides for platform-specific documentation
abstract class WatchConnectivityBase {
  /// The channel for communicating with the plugin's native code
  @protected
  final MethodChannel channel;

  final _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contextStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _transferFileStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of messages received
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  /// Stream of contexts received
  Stream<Map<String, dynamic>> get contextStream =>
      _contextStreamController.stream;

  /// Stream of transfer files received
  Stream<Map<String, dynamic>> get transferFileStream {
    // TODO: Implement for Android
    if (Platform.isIOS) {
      return _transferFileStreamController.stream;
    } else {
      throw UnsupportedError('Unsupported by Android');
    }
  }

  /// Create an instance of [WatchConnectivityBase] for the given
  /// [pluginName]
  WatchConnectivityBase({required String pluginName})
      : channel = MethodChannel(pluginName) {
    channel.setMethodCallHandler(_handle);
  }

  Future _handle(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveMessage':
        _messageStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'didReceiveApplicationContext':
        _contextStreamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'didReceiveTransferFile':
        // TODO: Implement for Android
        if (Platform.isIOS) {
          _transferFileStreamController
              .add(Map<String, dynamic>.from(call.arguments));
        }
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
    final applicationContext =
        await channel.invokeMapMethod<String, dynamic>('applicationContext');
    return applicationContext ?? {};
  }

  /// A dictionary containing the last update data received
  Future<List<Map<String, dynamic>>> get receivedApplicationContexts async {
    final receivedApplicationContexts =
        await channel.invokeListMethod<Map>('receivedApplicationContexts');
    return receivedApplicationContexts
            ?.map((e) => e.cast<String, dynamic>())
            .toList() ??
        [];
  }

  /// Send a message to all connected watches
  Future<void> sendMessage(Map<String, dynamic> message) {
    return channel.invokeMethod('sendMessage', message);
  }

  /// Update the application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) {
    return channel.invokeMethod('updateApplicationContext', context);
  }
}
