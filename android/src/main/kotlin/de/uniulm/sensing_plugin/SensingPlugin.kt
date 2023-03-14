package de.uniulm.sensing_plugin

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.exceptions.SensorNotRegisteredException
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Result
import de.uniulm.sensing_plugin.generated.ApiSensorManager.ResultWrapper
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorId
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorManagerApi
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorTaskResult
import de.uniulm.sensing_plugin.sensors.Gyroscope
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** SensingPlugin */
class SensingPlugin : FlutterPlugin, SensorManagerApi {
    private var eventChannels = hashMapOf<SensorId, EventChannel>()
    private var streamHandlers = hashMapOf<SensorId, SensorStreamHandler>()
    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private lateinit var sensorManager: SensorManager

    private val sensorIdMap = mapOf(
        SensorId.GYROSCOPE to Sensor.TYPE_GYROSCOPE
    )

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
        val isAvailable = if (sensorIdMap.containsKey(id)) {
            sensorManager.getSensorList(sensorIdMap[id]!!).isNotEmpty()
        } else {
            false
        }

        result?.success(isAvailable)
    }

    /**
     * Checks whether the sensor with the passed [SensorId] is currently used.
     *
     * 'used' means that tracking for this sensor was started in the past and has
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
        result: Result<ResultWrapper>?
    ) {
        val eventChannel = if (!eventChannels.containsKey(id)) {
            val eventChannel = EventChannel(messenger, "sensors/$id")
            eventChannels[id] = eventChannel
            eventChannel
        } else {
            eventChannels[id]
        }

        val taskResult = if (!streamHandlers.containsKey(id)) {
            val streamHandler =
                createSensorStreamHandlerFromId(id, sensorManager, timeIntervalInMilliseconds)
            streamHandlers[id] = streamHandler
            eventChannel!!.setStreamHandler(streamHandler)
            SensorTaskResult.SUCCESS
        } else {
            SensorTaskResult.ALREADY_TRACKING_SENSOR
        }

        val resultWrapper = ResultWrapper.Builder()
            .setState(taskResult)
            .build()

        result!!.success(resultWrapper)
    }

    private fun createSensorStreamHandlerFromId(
        id: SensorId,
        sensorManager: SensorManager,
        timeIntervalInMilliseconds: Long
    ) = when (id) {
            SensorId.GYROSCOPE -> Gyroscope(sensorManager, timeIntervalInMilliseconds)
            else -> throw NotImplementedError()
        }

    /** Stops tracking of the sensor with the passed [SensorId]. */
    override fun stopSensorTracking(
        id: SensorId,
        result: Result<ResultWrapper>?
    ) {
        val taskResult = if (streamHandlers.containsKey(id)) {
            val streamHandler = streamHandlers[id]!!
            streamHandler.stopListener()
            streamHandlers.remove(id)
            val eventChannel = eventChannels[id]!!
            eventChannel.setStreamHandler(null)
            SensorTaskResult.SUCCESS
        } else {
            SensorTaskResult.NOT_TRACKING_SENSOR
        }

        val resultWrapper = ResultWrapper.Builder()
            .setState(taskResult)
            .build()

        result!!.success(resultWrapper)
    }

    /**
     * Changes the interval of the sensor event channel with the passed
     * [SensorId] to [timeIntervalInMilliseconds] ms.
     */
    override fun changeSensorTimeInterval(
        id: SensorId,
        timeIntervalInMilliseconds: Long,
        result: Result<ResultWrapper>?
    ) {
        val taskResult = if (timeIntervalInMilliseconds < 0) {
            SensorTaskResult.INVALID_TIME_INTERVAL
        } else if (streamHandlers.containsKey(id)) {
            val timeIntervalInMicroseconds = timeIntervalInMilliseconds * 1000
            streamHandlers[id]!!.changeTimeInterval(timeIntervalInMicroseconds)
            SensorTaskResult.SUCCESS
        } else {
            SensorTaskResult.SENSOR_NOT_AVAILABLE
        }

        val resultWrapper = ResultWrapper.Builder()
            .setState(taskResult)
            .build()

        result!!.success(resultWrapper)
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
    override fun _dummyMethod(data: SensorData) { }

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
