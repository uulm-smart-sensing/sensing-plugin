package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorAccuracy
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit
import de.uniulm.sensing_plugin.getAccuracyEnumFromValue
import de.uniulm.sensing_plugin.streamhandlers.SensorStreamHandler

class HeadingSensor(
    private val sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SensorStreamHandler(
    sensorManager,
    sensorIds,
    timeIntervalInMilliseconds,
    Unit.DEGREES
),
    SensorEventListener {

    companion object {
        val sensorIds = intArrayOf(Sensor.TYPE_ACCELEROMETER, Sensor.TYPE_MAGNETIC_FIELD)
    }

    private val lastAccelerometerData = FloatArray(3)
    private var isAccelerometerDataSet = false
    private var accelerometerAccuracy = SensorAccuracy.NO_CONTACT
    private val lastMagnetometerData = FloatArray(3)
    private var isMagnetometerDataSet = false
    private var magnetometerAccuracy = SensorAccuracy.NO_CONTACT

    private val rotationMatrix = FloatArray(9)
    private val orientation = FloatArray(3)

    init {
        precision = 0
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
        // First sensor is Accelerometer, second is Magnetometer
        when (event.sensor) {
            sensors[0] -> {
                System.arraycopy(event.values, 0, lastAccelerometerData, 0, event.values.size)
                isAccelerometerDataSet = true
            }
            sensors[1] -> {
                System.arraycopy(event.values, 0, lastMagnetometerData, 0, event.values.size)
                isMagnetometerDataSet = true
            }
        }
        updateSensorData(event.timestamp)
    }

    /**
     * Called when the accuracy of the registered sensor has changed to the value [newAccuracy].
     *
     * [newAccuracy] is one of [SensorManager].SENSOR_STATUS_*.
     * Unlike onSensorChanged(), this is only called when this accuracy value changes.
     */
    override fun onAccuracyChanged(sensor: Sensor, newAccuracy: Int) {
        // First sensor is Accelerometer, second is Magnetometer
        when (sensor) {
            sensors[0] -> {
                accelerometerAccuracy = getAccuracyEnumFromValue(newAccuracy)
            }
            sensors[1] -> {
                magnetometerAccuracy = getAccuracyEnumFromValue(newAccuracy)
            }
        }
        updateAccuracy()
    }

    /**
     * Calculates heading with the data of the accelerometer and magnetometer.
     *
     * Source: https://developer.android.com/guide/topics/sensors/sensors_position#sensors-pos-orient
     */
    private fun updateSensorData(eventTimeInNanoseconds: Long) {
        if (!isAccelerometerDataSet || !isMagnetometerDataSet) {
            return
        }

        SensorManager.getRotationMatrix(
            rotationMatrix,
            null,
            lastAccelerometerData,
            lastMagnetometerData
        )
        SensorManager.getOrientation(rotationMatrix, orientation)
        val azimuthInRadians = orientation[0]
        val azimuthInDegrees = Math.toDegrees(azimuthInRadians.toDouble())
        if (sendSensorData(listOf(azimuthInDegrees), eventTimeInNanoseconds)) {
            isAccelerometerDataSet = false
            isMagnetometerDataSet = false
        }
    }

    private fun updateAccuracy() {
        accuracy = if (accelerometerAccuracy.ordinal > magnetometerAccuracy.ordinal) {
            accelerometerAccuracy
        } else {
            magnetometerAccuracy
        }
    }

    /**
     * Registers the listeners for this stream handler for the according [sensors] with the passed
     * [timeIntervalInMicroseconds].
     */
    override fun startListeners(timeIntervalInMicroseconds: Int) {
        sensorManager.registerListener(this, sensors[0], timeIntervalInMicroseconds)
        sensorManager.registerListener(this, sensors[1], timeIntervalInMicroseconds)
    }

    /** Unregisters the listeners for this stream handler for the according [sensors]. */
    override fun stopListeners() {
        sensorManager.unregisterListener(this)
    }
}
