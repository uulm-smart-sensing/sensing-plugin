package de.uniulm.sensing_plugin

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.SystemClock
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorTaskResult
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit
import io.flutter.plugin.common.EventChannel
import java.util.Calendar

abstract class SensorStreamHandler(
    private val sensorManager: SensorManager,
    sensorId: Int,
    private var timeIntervalInMilliseconds: Long,
    private val unit: Unit
) : EventChannel.StreamHandler, SensorEventListener {

    private val sensor: Sensor = sensorManager.getDefaultSensor(sensorId)
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdate: Calendar = Calendar.getInstance()
    private var accuracy: SensorAccuracy = SensorAccuracy.NO_CONTACT
    private var precision: Long = 0

    /** Creates a [SensorData] object from the passed [SensorEvent]. */
    private fun getSensorDataFromSensorEvent(event: SensorEvent): SensorData =
        SensorData.Builder()
            .setData(event.values.map { v -> v.toDouble() })
            .setMaxPrecision(precision)
            .setUnit(unit)
            .setTimestampInMicroseconds(convertSensorEventTimestampToUnixTimestamp(event.timestamp))
            .build()

    /**
     * Converts the timestamp of a [SensorEvent] to Unix timestamp with a precision in microseconds.
     *
     * [SensorEvent.timestamp] is the timestamp since boot of the device and needs to be synced with
     * the timestamp of the boot to get the actual Unix timestamp.
     *
     * For more information:
     * [StackOverflow](https://stackoverflow.com/questions/3498006/sensorevent-timestamp-to-absolute-utc-timestamp)
     */
    private fun convertSensorEventTimestampToUnixTimestamp(eventTimeInNanoseconds: Long): Long {
        // SystemClock.elapsedRealtimeNanos() returns the elapsed time since the device was booted.
        val bootTimestampInMicroseconds = ((System.currentTimeMillis() * 1000)
            - (SystemClock.elapsedRealtimeNanos() / 1000))
        // Add the event timestamp to the boot timestamp to get the unix timestamp of the event
        return bootTimestampInMicroseconds + (eventTimeInNanoseconds / 1000)
    }

    /**
     * Returns the [SensorInfo] object of the sensor.
     * This contains basic information about the sensor.
     */
    fun getSensorInfo(): SensorInfo =
        SensorInfo.Builder()
            .setAccuracy(accuracy)
            .setTimeIntervalInMilliseconds(timeIntervalInMilliseconds)
            .setUnit(unit)
            .build()

    /**
     * Called when the accuracy of the registered sensor has changed to the value [newAccuracy].
     *
     * [newAccuracy] is one of [SensorManager].SENSOR_STATUS_*.
     * Unlike onSensorChanged(), this is only called when this accuracy value changes.
     */
    override fun onAccuracyChanged(sensor: Sensor, newAccuracy: Int) {
        accuracy = getAccuracyEnumFromValue(newAccuracy)
        precision = getPrecisionFromResolution(sensor.resolution)
    }

    private fun getAccuracyEnumFromValue(accuracyValue: Int): SensorAccuracy =
        when (accuracyValue) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> SensorAccuracy.HIGH
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> SensorAccuracy.MEDIUM
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> SensorAccuracy.LOW
            SensorManager.SENSOR_STATUS_UNRELIABLE -> SensorAccuracy.UNRELIABLE
            SensorManager.SENSOR_STATUS_NO_CONTACT -> SensorAccuracy.NO_CONTACT
            else -> { throw IllegalArgumentException("Unexpected accuracy value '$accuracyValue'") }
        }

    /**
     * Evaluates the precision from the passed [resolution] of a sensor.
     *
     * Precision is the number of decimal places of a value to which the value is accurate.
     */
    private fun getPrecisionFromResolution(resolution: Float): Long {
        if (resolution < 1E-12) {
            return 12
        }
        var precision = 0L
        var res = resolution
        while (res < 1) {
            precision++
            res *= 10
        }
        return precision
    }

    /**
     * Called when there is a new sensor event.
     *
     * Note that "on changed" is somewhat of a misnomer, as this will also be called if we have a
     * new reading from a sensor with the exact same sensor values (but a newer timestamp).
     * List of all sensor events:
     * [SensorEvent](https://developer.android.com/reference/android/hardware/SensorEvent).
     */
    override fun onSensorChanged(event: SensorEvent) {
        val currentTime = Calendar.getInstance()
        if (isValidTime(currentTime)) {
            val sensorData = getSensorDataFromSensorEvent(event)
            eventSink?.success(sensorData.toList())
            lastUpdate = currentTime
        }
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
            startListener()
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
        stopListener()
    }

    /**
     * Registers this stream handler as the listener for the according [sensor] with the
     * configured [timeIntervalInMilliseconds].
     */
    private fun startListener() {
        val timeIntervalInMicroseconds = (timeIntervalInMilliseconds * 1000).toInt()
        sensorManager.registerListener(this, sensor, timeIntervalInMicroseconds)
    }

    /** Unregisters this stream handler as the listener for the according [sensor]. */
    fun stopListener() {
        sensorManager.unregisterListener(this)
    }

    /** Changes the interval of this listener to [timeIntervalInMilliseconds]. */
    fun changeTimeInterval(timeIntervalInMilliseconds: Long): SensorTaskResult {
        this.timeIntervalInMilliseconds = timeIntervalInMilliseconds
        stopListener()
        startListener()
        return SensorTaskResult.SUCCESS
    }

    /**
     * Checks whether time difference between the passed [time] and the [lastUpdate] is greater
     * than or equal to [timeIntervalInMilliseconds].
     */
    private fun isValidTime(time: Calendar): Boolean {
        return time.timeInMillis - lastUpdate.timeInMillis >= timeIntervalInMilliseconds
    }
}
