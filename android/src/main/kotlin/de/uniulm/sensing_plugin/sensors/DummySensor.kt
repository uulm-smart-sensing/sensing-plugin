package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.SensorStreamHandler
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit

class DummySensor(
    sensorManager: SensorManager,
    private val intervalInMicroseconds: Long,
) : SensorStreamHandler(
    sensorManager,
    Sensor.TYPE_ACCELEROMETER,
    intervalInMicroseconds,
) {

    override fun createSensorData(event: SensorEvent) {
        TODO("Not yet implemented")
    }

    override fun getSensorInfo(): SensorInfo {
        return SensorInfo.Builder()
            .setAccuracy(0)
            .setTimeIntervalInMilliseconds(intervalInMicroseconds)
            .setUnit(Unit.UNITLESS)
            .build()
    }
}
