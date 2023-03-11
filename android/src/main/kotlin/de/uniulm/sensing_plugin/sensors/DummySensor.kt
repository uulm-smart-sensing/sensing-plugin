package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.SensorStreamHandler
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

    override fun getSensorDataMapFromSensorEvent(event: SensorEvent): Map<String, Any> =
        mapOf(
            "data" to event.values.map { v -> v.toDouble() },
            "maxPrecision" to 100,
            "unit" to Unit.UNITLESS
        )


    override fun getSensorInfo(): SensorInfo =
        SensorInfo.Builder()
            .setAccuracy(0)
            .setTimeIntervalInMilliseconds(getTimeIntervalInMicroseconds())
            .setUnit(Unit.UNITLESS)
            .build()
}
