package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorUnit
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class LinearAccelerationSensor(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SingleSensorStreamHandler(
    sensorManager,
    sensorId,
    timeIntervalInMilliseconds,
    SensorUnit.METERS_PER_SECOND_SQUARED
) {
    companion object {
        const val sensorId = Sensor.TYPE_LINEAR_ACCELERATION
    }
}
