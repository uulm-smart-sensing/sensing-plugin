package de.uniulm.sensing_plugin

import android.content.Context
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.exceptions.SensorNotRegisteredException
import de.uniulm.sensing_plugin.generated.ApiSensorManager.*
import de.uniulm.sensing_plugin.sensors.DummySensor
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
        result!!.success(streamHandlers.containsKey(id))
    }

    override fun startSensorTracking(
        id: SensorId,
        timeIntervalInMilliseconds: Long,
        result: Result<StateIndicator>?
    ) {
        val eventChannel = if (!eventChannels.containsKey(id)) {
            val eventChannel = EventChannel(messenger, "sensors/$id")
            eventChannels[id] = eventChannel
            eventChannel
        } else {
            eventChannels[id]
        }

        val state = if (!streamHandlers.containsKey(id)) {
            val streamHandler = when(id) {
                SensorId.ACCELEROMETER -> DummySensor(sensorManager, timeIntervalInMilliseconds)
                else -> throw NotImplementedError()
            }
            streamHandlers[id] = streamHandler
            eventChannel!!.setStreamHandler(streamHandler)
            State.SUCCESS
        } else {
            // TODO: replace with something like State.ALREADY_TRACKING
            State.FAIL
        }

        val stateIndicator = StateIndicator.Builder()
            .setState(state)
            .build()

        result!!.success(stateIndicator)
    }

    override fun stopSensorTracking(
        id: SensorId,
        result: Result<StateIndicator>?
    ) {
        if (streamHandlers.containsKey(id)) {
            val streamHandler = streamHandlers[id]!!
            streamHandler.stopListener()
            streamHandlers.remove(id)
            val eventChannel = eventChannels[id]!!
            eventChannel.setStreamHandler(null)
        }
    }

    override fun changeSensorTimeInterval(
        id: SensorId,
        timeIntervalInMilliseconds: Long,
        result: Result<StateIndicator>?
    ) {
        val state = if (streamHandlers.containsKey(id)) {
            val timeIntervalInMicroseconds = timeIntervalInMilliseconds * 1000
            streamHandlers[id]!!.changeTimeInterval(timeIntervalInMicroseconds)
            State.SUCCESS
        } else {
            State.FAIL
        }

        val stateIndicator = StateIndicator.Builder()
            .setState(state)
            .build()

        result!!.success(stateIndicator)
    }

    override fun getSensorInfo(
        id: SensorId,
        result: Result<SensorInfo>?
    ) {
        if (streamHandlers.containsKey(id)) {
            val streamHandler = streamHandlers[id]!!
            result!!.success(streamHandler.getSensorInfo())
        } else {
            result!!.error(SensorNotRegisteredException(id))
        }
    }

    override fun dummyMethod(data: SensorData) { }

    private fun removeAllListeners() {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
        }
    }
}
