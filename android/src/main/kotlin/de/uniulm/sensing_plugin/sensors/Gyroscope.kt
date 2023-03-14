package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.SensorStreamHandler
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit

class Gyroscope(
    sensorManager: SensorManager,
    timeIntervalInMicroseconds: Long
) : SensorStreamHandler(
    sensorManager,
    Sensor.TYPE_GYROSCOPE,
    timeIntervalInMicroseconds
) {

    /** Creates a [SensorData] object from the passed [SensorEvent]. */
    override fun getSensorDataFromSensorEvent(event: SensorEvent): SensorData =
        SensorData.Builder()
            .setData(event.values.map { v -> v.toDouble() })
            .setMaxPrecision(100)
            .setUnit(Unit.RADIANS_PER_SECOND)
            .build()

    /**
     * Returns the [SensorInfo] object of the sensor.
     * This contains basic information about the sensor.
     */
    override fun getSensorInfo(): SensorInfo =
        SensorInfo.Builder()
            .setAccuracy(0)
            .setTimeIntervalInMilliseconds(getTimeIntervalInMicroseconds())
            .setUnit(Unit.RADIANS_PER_SECOND)
            .build()
}
