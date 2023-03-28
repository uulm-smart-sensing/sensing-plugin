package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class Accelerometer(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SingleSensorStreamHandler(
    sensorManager,
    sensorId,
    timeIntervalInMilliseconds,
    ApiSensorManager.Unit.METERS_PER_SECOND_SQUARED
) {
    companion object {
        const val sensorId = Sensor.TYPE_ACCELEROMETER
    }
}
