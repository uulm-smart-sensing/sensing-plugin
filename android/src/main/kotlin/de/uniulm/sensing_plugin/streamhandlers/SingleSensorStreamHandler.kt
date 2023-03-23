package de.uniulm.sensing_plugin.streamhandlers

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager
import de.uniulm.sensing_plugin.getAccuracyEnumFromValue
import de.uniulm.sensing_plugin.getPrecisionFromResolution

/**
 * Simplified version of [SensorStreamHandler] that only uses one sensor.
 */
abstract class SingleSensorStreamHandler(
    private val sensorManager: SensorManager,
    sensorId: Int,
    timeIntervalInMilliseconds: Long,
    unit: ApiSensorManager.Unit
) : SensorStreamHandler(
    sensorManager,
    intArrayOf(sensorId),
    timeIntervalInMilliseconds,
    unit
),
    SensorEventListener {

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

    /**
     * Called when there is a new sensor event.
     *
     * Note that "on changed" is somewhat of a misnomer, as this will also be called if we have a
     * new reading from a sensor with the exact same sensor values (but a newer timestamp).
     * List of all sensor events:
     * [SensorEvent](https://developer.android.com/reference/android/hardware/SensorEvent).
     */
    override fun onSensorChanged(event: SensorEvent) {
        sendSensorData(event.values.map { v -> v.toDouble() }, event.timestamp)
    }

    /**
     * Registers the listeners for this stream handler for the according [sensors] with the passed
     * [timeIntervalInMicroseconds].
     */
    override fun startListeners(timeIntervalInMicroseconds: Int) {
        sensorManager.registerListener(this, sensors.first(), timeIntervalInMicroseconds)
    }

    /** Unregisters the listeners for this stream handler for the according [sensors]. */
    override fun stopListeners() {
        sensorManager.unregisterListener(this)
    }
}
