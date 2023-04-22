package de.uniulm.sensing_plugin.streamhandlers

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.convertSensorEventTimestampToUnixTimestamp
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorAccuracy
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.InternalSensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorTaskResult
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit
import de.uniulm.sensing_plugin.toList
import io.flutter.plugin.common.EventChannel

/**
 * [EventChannel.StreamHandler] for a variable amount of sensors (all of [sensors]).
 *
 * Provides information about the data which is sent by this [SensorStreamHandler] by using
 * [getSensorInfo].
 * When [startListeners] is called, all listeners for [sensors] are registered and sensor data is
 * sent via the [EventChannel] at the configured [timeIntervalInMilliseconds].
 * With [stopListeners] the listeners are unregistered and this [SensorStreamHandler] will send
 * nothing.
 * At last [changeTimeInterval] changes the interval at which the [SensorStreamHandler] will send
 * data.
 */
abstract class SensorStreamHandler(
    sensorManager: SensorManager,
    sensorIds: IntArray,
    private var timeIntervalInMilliseconds: Long,
    private val unit: Unit
) : EventChannel.StreamHandler {

    protected val sensors: Array<Sensor> = sensorIds
        .map { sensorManager.getDefaultSensor(it) }
        .toTypedArray()
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdateTimestampInMilliseconds: Long = System.currentTimeMillis()
    protected var accuracy: SensorAccuracy = SensorAccuracy.NO_CONTACT
    protected var precision: Long = 0

    /**
     * Returns the [InternalSensorInfo] object of this sensor.
     * This contains basic information about this sensor.
     *
     * The sensor will report data with an [accuracy] in the specified
     * [timeIntervalInMilliseconds]. The values will be in the fixed [unit].
     */
    fun getSensorInfo(): InternalSensorInfo =
        InternalSensorInfo.Builder()
            .setAccuracy(accuracy)
            .setTimeIntervalInMilliseconds(timeIntervalInMilliseconds)
            .setUnit(unit)
            .build()

    /**
     * Sends a [SensorData] object with the passed values to the Flutter side via the [EventChannel]
     *
     * If the method is called too early ie. when the time since the last data transmission is less
     * than the configured [timeIntervalInMilliseconds], then the method returns false; otherwise
     * true.
     */
    protected fun sendSensorData(data: List<Double>, eventTimeInNanoseconds: Long): Boolean {
        val currentTime = System.currentTimeMillis()
        if (!isValidTime(currentTime)) {
            return false
        }
        val sensorData = SensorData.Builder()
            .setData(data)
            .setMaxPrecision(precision)
            .setUnit(unit)
            .setTimestampInMicroseconds(
                convertSensorEventTimestampToUnixTimestamp(eventTimeInNanoseconds)
            )
            .build()
        eventSink?.success(sensorData.toList())
        lastUpdateTimestampInMilliseconds = currentTime
        return true
    }

    /**
     * Handles a request to set up an event stream.
     *
     * Any uncaught exception thrown by this method will be caught by the channel implementation
     * and logged. An error result message will be sent back to Flutter.
     * [eventSink] is an [EventChannel.EventSink] for emitting events to the Flutter receiver.
     * [arguments] are the stream configuration arguments. They may be null.
     */
    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        if (eventSink != null) {
            this.eventSink = eventSink
            val timeIntervalInMicroseconds = (timeIntervalInMilliseconds * 1000).toInt()
            startListeners(timeIntervalInMicroseconds)
        }
    }

    /**
     * Handles a request to tear down the most recently created event stream.
     *
     * Any uncaught exception thrown by this method will be caught by the channel implementation
     * and logged. An error result message will be sent back to Flutter.
     *
     * The channel implementation may call this method with [arguments] being null, to separate a
     * pair of two consecutive set up requests. Such request pairs may occur during Flutter hot
     * restart. Any uncaught exception thrown in this situation will be logged without notifying
     * Flutter.
     */
    override fun onCancel(arguments: Any?) {
        stopListeners()
    }

    /**
     * Registers the listeners for this stream handler for the according [sensors] with the passed
     * [timeIntervalInMicroseconds].
     */
    abstract fun startListeners(timeIntervalInMicroseconds: Int)

    /** Unregisters the listeners for this stream handler for the according [sensors]. */
    abstract fun stopListeners()

    /** Changes the interval of this listener to [timeIntervalInMilliseconds]. */
    fun changeTimeInterval(timeIntervalInMilliseconds: Long): SensorTaskResult {
        this.timeIntervalInMilliseconds = timeIntervalInMilliseconds
        val timeIntervalInMicroseconds = (timeIntervalInMilliseconds * 1000).toInt()
        stopListeners()
        startListeners(timeIntervalInMicroseconds)
        return SensorTaskResult.SUCCESS
    }

    /**
     * Checks whether time difference between the passed [timestampInMilliseconds] and
     * [lastUpdateTimestampInMilliseconds] is greater than or equal to [timeIntervalInMilliseconds].
     */
    private fun isValidTime(timestampInMilliseconds: Long): Boolean {
        val difference = timestampInMilliseconds - lastUpdateTimestampInMilliseconds
        return difference >= timeIntervalInMilliseconds
    }
}
