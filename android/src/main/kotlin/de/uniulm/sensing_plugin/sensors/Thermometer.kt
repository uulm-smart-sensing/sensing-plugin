package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorUnit
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class Thermometer(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SingleSensorStreamHandler(
    sensorManager,
    sensorId,
    timeIntervalInMilliseconds,
    SensorUnit.CELSIUS
) {
    companion object {
        const val sensorId = Sensor.TYPE_AMBIENT_TEMPERATURE
    }
}
