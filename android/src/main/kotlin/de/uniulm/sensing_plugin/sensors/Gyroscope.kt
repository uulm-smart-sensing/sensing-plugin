package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit
import de.uniulm.sensing_plugin.streamhandlers.SingleSensorStreamHandler

class Gyroscope(
    sensorManager: SensorManager,
    timeIntervalInMilliseconds: Long
) : SingleSensorStreamHandler(
    sensorManager,
    Sensor.TYPE_GYROSCOPE,
    timeIntervalInMilliseconds,
    Unit.RADIANS_PER_SECOND
)
