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

    /** Checks whether the sensor with the passed [SensorId] is available. */
    override fun isSensorAvailable(id: SensorId, result: Result<Boolean>?) {
        if (streamHandlers.containsKey(id)) {
            val isAvailable = streamHandlers[id]!!.isAvailable()
            result?.success(isAvailable)
        } else {
            result?.success(false)
        }
    }

    /**
     * Checks whether the sensor with the passed [SensorId] is currently used.
     *
     * 'used' means that tracking for this sensor started in the passed and has
     * not yet been stopped.
     */
    override fun isSensorUsed(
        id: SensorId,
        result: Result<Boolean>?
    ) {
        result!!.success(streamHandlers.containsKey(id))
    }

    /**
     * Starts tracking of the sensor with the passed [SensorId].
     *
     * The sensor sends data via the event channel every
     * [timeIntervalInMilliseconds] ms.
     */
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

    /** Stops tracking of the sensor with the passed [SensorId]. */
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

    /**
     * Changes the interval of the sensor event channel with the passed
     * [SensorId] to [timeIntervalInMilliseconds] ms.
     */
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

    /** Retrieves information about the sensor with the passed [SensorId]. */
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

    /**
     * [SensorData] isn't used in any method but returned via the event channel.
     *
     * For the class to be generated on the platforms it must be referenced in at
     * least one method.
     */
    override fun dummyMethod(data: SensorData) { }

    /**
     * Removes the stream handler of each event channels in [eventChannels].
     * The listener of the stream handler is stopped in the process.
     */
    private fun removeAllListeners() {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
        }
    }
}
