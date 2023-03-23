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
    private val timeIntervalInMilliseconds: Long
) : SensorStreamHandler(
    sensorManager,
    intArrayOf(Sensor.TYPE_ACCELEROMETER, Sensor.TYPE_MAGNETIC_FIELD),
    timeIntervalInMilliseconds,
    Unit.DEGREES
) {

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

    private val accelerometerListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            System.arraycopy(event.values, 0, lastAccelerometerData, 0, event.values.size)
            isAccelerometerDataSet = true
            updateSensorData(event.timestamp)
        }

        override fun onAccuracyChanged(sensor: Sensor, newAccuracy: Int) {
            accelerometerAccuracy = getAccuracyEnumFromValue(newAccuracy)
            updateAccuracy()
        }
    }

    private val magnetometerListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            System.arraycopy(event.values, 0, lastMagnetometerData, 0, event.values.size)
            isMagnetometerDataSet = true
            updateSensorData(event.timestamp)
        }

        override fun onAccuracyChanged(sensor: Sensor, newAccuracy: Int) {
            magnetometerAccuracy = getAccuracyEnumFromValue(newAccuracy)
            updateAccuracy()
        }
    }

    /**
     * Calculates heading
     *
     * Source: https://developer.android.com/guide/topics/sensors/sensors_position#sensors-pos-orient
     */
    private fun updateSensorData(eventTimeInNanoseconds: Long) {
        if (isAccelerometerDataSet && isMagnetometerDataSet) {
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
    }

    private fun updateAccuracy() {
        accuracy = if (accelerometerAccuracy.ordinal > magnetometerAccuracy.ordinal) {
            accelerometerAccuracy
        } else {
            magnetometerAccuracy
        }
    }

    /**
     * Registers the listeners for this stream handler for the according [sensors] with the
     * configured [timeIntervalInMilliseconds].
     */
    override fun startListeners(timeIntervalInMicroseconds: Int) {
        sensorManager.registerListener(
            accelerometerListener,
            sensors[0],
            timeIntervalInMicroseconds
        )
        sensorManager.registerListener(magnetometerListener, sensors[1], timeIntervalInMicroseconds)
    }

    /** Unregisters the listeners for this stream handler for the according [sensors]. */
    override fun stopListeners() {
        sensorManager.unregisterListener(accelerometerListener)
        sensorManager.unregisterListener(magnetometerListener)
    }
}
