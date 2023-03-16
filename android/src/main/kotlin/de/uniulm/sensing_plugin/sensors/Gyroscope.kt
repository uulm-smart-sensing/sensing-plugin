package de.uniulm.sensing_plugin.sensors

import android.hardware.Sensor
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.SensorStreamHandler
import de.uniulm.sensing_plugin.generated.ApiSensorManager.Unit

class Gyroscope(
    sensorManager: SensorManager,
    timeIntervalInMicroseconds: Long
) : SensorStreamHandler(
    sensorManager,
    Sensor.TYPE_GYROSCOPE,
    timeIntervalInMicroseconds,
    Unit.RADIANS_PER_SECOND
)
