package de.uniulm.sensing_plugin

import android.content.Context
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** SensingPlugin */
class SensingPlugin: FlutterPlugin, SensorManagerApi {
    private var eventChannels = hashMapOf<SensorId, EventChannel>()
    private var streamHandlers = hashMapOf<SensorId, SensorStreamHandler>()
    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private lateinit var sensorManager: SensorManager

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.context = binding.applicationContext
        this.messenger = binding.binaryMessenger
        this.sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        SensorManagerApi.setup(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        removeAllListeners()
        SensorManagerApi.setup(binding.binaryMessenger, null)
    }

    private fun removeAllListeners() {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
        }
    }

    override fun isSensorAvailable(
        id: SensorId,
        result: Result<Boolean>?
    ) {
        if (streamHandlers.containsKey(id)) {
            val isAvailable = streamHandlers[id]!!.isAvailable()
            result?.success(isAvailable)
        } else {
            result?.success(false)
        }
    }

    override fun isSensorUsed(
        id: SensorId,
        result: Result<Boolean>?
    ) {
        TODO("Not yet implemented")
    }

    override fun stopSensorTracking(
        id: SensorId,
        result: Result<StateIndicator>?
    ) {
        TODO("Not yet implemented")
    }

    override fun getSensorInfo(
        id: SensorId,
        result: Result<SensorInfo>?
    ) {
        TODO("Not yet implemented")
    }

    override fun changeSensorTimeInterval(
        timeIntervalInMilliseconds: Long,
        result: Result<StateIndicator>?
    ) {
        /**
         * Requires sensor id.
         */
//        val state = if (streamHandlers.containsKey(id)) {
//            val timeIntervalInMicroseconds = timeIntervalInMilliseconds * 1000
//            streamHandlers[id]!!.changeTimeInterval(timeIntervalInMicroseconds)
//        } else {
//            State.FAIL
//        }
//
//        val stateIndicator = StateIndicator.Builder()
//            .setState(state)
//            .build()
//
//        result!!.success(stateIndicator)
        TODO("Not yet implemented")
    }

    override fun startSensorTracking(
        id: SensorId,
        timeIntervalInMilliseconds: Long,
        result: Result<StateIndicator>?
    ) {
        TODO("Not yet implemented")
    }
}
