package dev.rexios.watch_connectivity

import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import com.google.android.gms.wearable.*
import com.google.android.gms.wearable.DataEvent.TYPE_CHANGED
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream


/** WatchConnectivityPlugin */
class WatchConnectivityPlugin : FlutterPlugin, MethodCallHandler, WearableListenerService() {
    private val channelName = "watch_connectivity"

    /// Since the flutter plugin and android service are two different instances of this class,
    /// we must make properties needed by both static
    companion object {
        private lateinit var channel: MethodChannel
        private lateinit var localNode: Node
    }

    /// Package manager comes from the WearableListenerService context, but it's invalid here
    private lateinit var mPackageManager: PackageManager
    private lateinit var nodeClient: NodeClient
    private lateinit var messageClient: MessageClient
    private lateinit var dataClient: DataClient

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)

        val context = flutterPluginBinding.applicationContext

        mPackageManager = context.packageManager
        nodeClient = Wearable.getNodeClient(context)
        messageClient = Wearable.getMessageClient(context)
        dataClient = Wearable.getDataClient(context)

        nodeClient.localNode.addOnSuccessListener { localNode = it }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // Getters
            "isSupported" -> result.success(true)
            "isPaired" -> isPaired(result)
            "isReachable" -> isReachable(result)
            "applicationContext" -> applicationContext(result)
            "receivedApplicationContexts" -> receivedApplicationContexts(result)

            // Methods
            "sendMessage" -> sendMessage(call, result)
            "updateApplicationContext" -> updateApplicationContext(call, result)

            // Not implemented
            else -> result.notImplemented()
        }
    }

    private fun runOnUiThread(runnable: () -> Unit) {
        Handler(Looper.getMainLooper()).post { runnable() }
    }

    private fun invokeOnUiThread(method: String, arguments: Any?, callback: Result? = null) {
        runOnUiThread { channel.invokeMethod(method, arguments, callback) }
    }

    private fun objectToBytes(`object`: Any): ByteArray {
        val baos = ByteArrayOutputStream()
        val oos = ObjectOutputStream(baos)
        oos.writeObject(`object`)
        return baos.toByteArray()
    }

    private fun objectFromBytes(bytes: ByteArray): Any {
        val bis = ByteArrayInputStream(bytes)
        val ois = ObjectInputStream(bis)
        return ois.readObject()
    }

    private fun isPaired(result: Result) {
        val apps = mPackageManager.getInstalledApplications(0)
        val wearAppInstalled =
            apps.any { it.packageName == "com.google.android.wearable.app" }
        val galaxyWearAppInstalled =
            apps.any { it.packageName == "com.samsung.android.app.watchmanager" }
        result.success(wearAppInstalled || galaxyWearAppInstalled)
    }

    private fun isReachable(result: Result) {
        nodeClient.connectedNodes
            .addOnSuccessListener { result.success(it.isNotEmpty()) }
            .addOnFailureListener { result.error(it.message, it.localizedMessage, it) }
    }

    private fun applicationContext(result: Result) {
        dataClient.dataItems
            .addOnSuccessListener { items ->
                val localNodeItem = items.firstOrNull {
                    // Only elements from the local node (there should only be one)
                    it.uri.host == localNode.id && it.uri.path == "/$channelName"
                }
                if (localNodeItem != null) {
                    val itemContent = objectFromBytes(localNodeItem.data)
                    result.success(itemContent)
                } else {
                    result.success(emptyMap<String, Any>())
                }
            }.addOnFailureListener { result.error(it.message, it.localizedMessage, it) }
    }

    private fun receivedApplicationContexts(result: Result) {
        dataClient.dataItems
            .addOnSuccessListener { items ->
                val itemContents = items.filter {
                    // Elements that are not from the local node
                    it.uri.host != localNode.id && it.uri.path == "/$channelName"
                }.map { objectFromBytes(it.data) }
                result.success(itemContents)
            }.addOnFailureListener { result.error(it.message, it.localizedMessage, it) }
    }

    private fun sendMessage(call: MethodCall, result: Result) {
        val messageData = objectToBytes(call.arguments)
        nodeClient.connectedNodes.addOnSuccessListener { nodes ->
            nodes.forEach { messageClient.sendMessage(it.id, channelName, messageData) }
            result.success(null)
        }.addOnFailureListener { result.error(it.message, it.localizedMessage, it) }
    }

    private fun updateApplicationContext(call: MethodCall, result: Result) {
        val eventData = objectToBytes(call.arguments)
        val dataItem = PutDataRequest.create("/$channelName")
        dataItem.data = eventData
        dataClient.putDataItem(dataItem)
            .addOnSuccessListener { result.success(null) }
            .addOnFailureListener { result.error(it.message, it.localizedMessage, it) }

    }

    override fun onMessageReceived(message: MessageEvent) {
        val messageContent = objectFromBytes(message.data)
        invokeOnUiThread("didReceiveMessage", messageContent)
    }

    override fun onDataChanged(dataItems: DataEventBuffer) {
        dataItems
            .filter {
                it.type == TYPE_CHANGED
                        && it.dataItem.uri.host != localNode.id
                        && it.dataItem.uri.path == "/$channelName"
            }
            .forEach { item ->
                val eventContent = objectFromBytes(item.dataItem.data)
                invokeOnUiThread("didReceiveApplicationContext", eventContent)
            }
    }
}
