package de.uniulm.sensing_plugin

import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData

/**
 * Converts this [SensorData] object to a list, with the class properties as list elements.
 *
 * This is used to send the [SensorData] object via an EventChannel to the Flutter side.
 * Sending the object directly causes an error, therefore it is sent as list representation, which
 * is the only way an object can be send via an EventChannel.
 */
fun SensorData.toList(): ArrayList<Any> {
    val list = ArrayList<Any>()
    list.add(this.data)
    list.add(this.maxPrecision)
    list.add(this.unit)
    return list
}
