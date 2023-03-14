package de.uniulm.sensing_plugin

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorTaskResult
import io.flutter.plugin.common.EventChannel
import java.util.Calendar

abstract class SensorStreamHandler(
    private val sensorManager: SensorManager,
    sensorId: Int,
    private var timeIntervalInMicroseconds: Long
) : EventChannel.StreamHandler, SensorEventListener {

    private val sensor: Sensor = sensorManager.getDefaultSensor(sensorId)
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdate: Calendar = Calendar.getInstance()

    /** Creates a [SensorData] object from the passed [SensorEvent]. */
    abstract fun getSensorDataFromSensorEvent(event: SensorEvent): SensorData

    /**
     * Returns the [SensorInfo] object of the sensor.
     * This contains basic information about the sensor.
     */
    abstract fun getSensorInfo(): SensorInfo

    /**
     * Called when the accuracy of the registered sensor has changed to the value [i].
     *
     * [i] is one of [SensorManager].SENSOR_STATUS_*.
     * Unlike onSensorChanged(), this is only called when this accuracy value changes.
     */
    override fun onAccuracyChanged(sensor: Sensor, i: Int) { }

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
     * configured [timeIntervalInMicroseconds].
     */
    private fun startListener() {
        sensorManager.registerListener(this, sensor, timeIntervalInMicroseconds.toInt())
    }

    /** Unregisters this stream handler as the listener for the according [sensor]. */
    fun stopListener() {
        sensorManager.unregisterListener(this)
    }

    /** Changes the interval of this listener to [timeIntervalInMicroseconds]. */
    fun changeTimeInterval(timeIntervalInMicroseconds: Long): SensorTaskResult {
        this.timeIntervalInMicroseconds = timeIntervalInMicroseconds
        stopListener()
        startListener()
        return SensorTaskResult.SUCCESS
    }

    /**
     * Checks whether time difference between the passed [time] and the [lastUpdate] is greater
     * than or equal to [timeIntervalInMicroseconds].
     */
    private fun isValidTime(time: Calendar): Boolean {
        return (time.timeInMillis - lastUpdate.timeInMillis) * 1000 >= timeIntervalInMicroseconds
    }

    fun getTimeIntervalInMicroseconds() = timeIntervalInMicroseconds
}
