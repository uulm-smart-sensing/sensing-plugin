package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorUnit
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class Magnetometer(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SingleSensorStreamHandler(
    sensorManager,
    sensorId,
    timeIntervalInMilliseconds,
    SensorUnit.MICRO_TESLAS
) {
    companion object {
        const val sensorId = Sensor.TYPE_MAGNETIC_FIELD
    }
}
