package de.uniulm.sensor_demo

import android.content.Context
import android.hardware.SensorManager
import de.uniulm.sensor_demo.generated.Messages
import de.uniulm.sensor_demo.generated.Messages.Api2Host

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** SensorDemoPlugin */
class SensorDemoPlugin: FlutterPlugin, Api2Host {
    private var eventChannels = hashMapOf<Int, EventChannel>()
    private var streamHandlers = hashMapOf<Int, SensorStreamHandler>()
    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private lateinit var sensorManager: SensorManager

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = binding.applicationContext
        this.messenger = binding.binaryMessenger
        this.sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        Api2Host.setup(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        removeAllListeners()
        Api2Host.setup(binding.binaryMessenger, null)
    }

    private fun removeAllListeners() {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
        }
    }

    override fun isSensorAvailable(sensorId: Long, result: Messages.Result<Boolean>?) {
        val isAvailable = sensorManager.getSensorList(sensorId.toInt()).isNotEmpty()
        result?.success(isAvailable)
    }

    override fun updateSensorInterval(
        sensorId: Long,
        newInterval: Long,
        result: Messages.Result<Boolean>?
    ) {
        try {
            streamHandlers[sensorId.toInt()]?.updateInterval(newInterval.toInt())
            result?.success(true)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            result?.success(false)
        }
    }

    override fun startEventChannel(
        sensorId: Long,
        interval: Long,
        result: Messages.Result<Boolean>?
    ) {
        try {
            if (!eventChannels.containsKey(sensorId.toInt())) {
                val eventChannel = EventChannel(messenger, "sensors/$sensorId")
                val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
                val sensorStreamHandler = SensorStreamHandler(sensorManager, sensorId.toInt(), interval.toInt())
                eventChannel.setStreamHandler(sensorStreamHandler)
                eventChannels[sensorId.toInt()] = eventChannel
                streamHandlers[sensorId.toInt()] = sensorStreamHandler
            }
            result?.success(true)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
            result?.success(false)
        }
    }
}
