package dev.rexios.watch_connectivity

import androidx.annotation.NonNull
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.CapabilityApi.FILTER_ALL
import com.google.android.gms.wearable.CapabilityApi.FILTER_REACHABLE
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.Wearable

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** WatchConnectivityPlugin */
class WatchConnectivityPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var capabilityClient: CapabilityClient

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "watch_connectivity")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val context = binding.activity
        capabilityClient = Wearable.getCapabilityClient(context)
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isPaired" -> capabilityClient.getAllCapabilities(FILTER_ALL)
                .addOnSuccessListener { result.success(it.isNotEmpty()) }
                .addOnFailureListener { result.error(it.message, it.localizedMessage, it) }

            "isReachable" -> capabilityClient.getAllCapabilities(FILTER_REACHABLE)
                .addOnSuccessListener { result.success(it.isNotEmpty()) }
                .addOnFailureListener { result.error(it.message, it.localizedMessage, it) }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
