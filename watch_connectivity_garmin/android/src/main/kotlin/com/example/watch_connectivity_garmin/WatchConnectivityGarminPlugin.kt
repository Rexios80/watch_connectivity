package com.example.watch_connectivity_garmin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** WatchConnectivityGarminPlugin */
class WatchConnectivityGarminPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var packageManager: PackageManager

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "watch_connectivity_garmin")
    channel.setMethodCallHandler(this)

    val context = flutterPluginBinding.applicationContext

    packageManager = context.packageManager
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        // Getters
        "isSupported" -> isSupported(result)
        "isPaired" -> isPaired(result)
        "isReachable" -> isReachable(result)
        "applicationContext" -> result.notImplemented()
        "receivedApplicationContexts" -> result.notImplemented()

        // Methods
        "sendMessage" -> sendMessage(call, result)
        "updateApplicationContext" -> result.notImplemented()

        // Not implemented
        else -> result.notImplemented()
    }
  }

  private fun isSupported(result: Result) {
      val apps = packageManager.getInstalledApplications(0)
      val wearableAppInstalled = apps.any { it.packageName == "com.garmin.android.apps.connectmobile" }
      result.success(wearableAppInstalled)
  }

  private fun isPaired(result: Result) {
    // TODO
  }

  private fun isReachable(result: Result) {
    // TODO
  }

  private fun sendMessage(call: MethodCall, result: Result) {
    // TODO
  }
}
