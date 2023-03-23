package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class Barometer(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long,
    unit: Unit
) : SingleSensorStreamHandler(
    sensorManager,
    sensorId,
    timeIntervalInMilliseconds,
    unit
) {
    companion object {
        const val sensorId = Sensor.TYPE_PRESSURE
    }
}
