package de.uniulm.sensing_plugin.exceptions

import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorId

class SensorNotRegisteredException(private val id : SensorId) : RuntimeException() {
    override val message: String
        get() = "Sensor $id is not registered"
}
