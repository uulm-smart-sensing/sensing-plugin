package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.SensorStreamHandler
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit

class DummySensor(
    sensorManager: SensorManager,
    timeIntervalInMicroseconds: Long,
) : SensorStreamHandler(
    sensorManager,
    Sensor.TYPE_ACCELEROMETER,
    timeIntervalInMicroseconds,
) {

    override fun createSensorDataFromEvent(event: SensorEvent): SensorData {
        return SensorData.Builder()
            .setData(event.values.map { v -> v.toDouble() })
            .setMaxPrecision(100)
            .setUnit(Unit.UNITLESS)
            .build()
    }

    override fun getSensorInfo(): SensorInfo {
        return SensorInfo.Builder()
            .setAccuracy(0)
            .setTimeIntervalInMilliseconds(getTimeIntervalInMicroseconds())
            .setUnit(Unit.UNITLESS)
            .build()
    }
}
