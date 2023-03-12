package de.uniulm.sensing_plugin

import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData

/** Converts this [SensorData] object to a list, with the class properties as list elements. */
fun SensorData.toList(): ArrayList<Any> {
    val list = ArrayList<Any>()
    list.add(this.data)
    list.add(this.maxPrecision)
    list.add(this.unit)
    return list
}
