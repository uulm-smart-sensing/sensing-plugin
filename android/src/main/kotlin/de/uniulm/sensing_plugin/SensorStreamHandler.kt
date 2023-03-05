package de.uniulm.sensing_plugin

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorData
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorInfo
import de.uniulm.sensing_plugin.generated.ApiSensorManager.State
import io.flutter.plugin.common.EventChannel
import java.util.*

abstract class SensorStreamHandler(
    private val sensorManager: SensorManager,
    private val sensorId: Int,
    private var timeIntervalInMicroseconds: Long
) : EventChannel.StreamHandler, SensorEventListener {

    private val sensor: Sensor = sensorManager.getDefaultSensor(sensorId)
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdate: Calendar = Calendar.getInstance()

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        if (eventSink != null) {
            this.eventSink = eventSink
            startListener()
        }
    }

    override fun onCancel(arguments: Any?) {
        stopListener()
    }

    private fun startListener() {
        sensorManager.registerListener(this, sensor, timeIntervalInMicroseconds.toInt())
    }

    fun stopListener() {
        sensorManager.unregisterListener(this)
    }

    override fun onAccuracyChanged(sensor: Sensor, i: Int) {
    }

    override fun onSensorChanged(event: SensorEvent) {
        val currentTime = Calendar.getInstance()
        if (isValidTime(currentTime)) {
            val sensorData = createSensorDataFromEvent(event)
            eventSink?.success(sensorData)
            lastUpdate = currentTime
        }
    }

    abstract fun createSensorDataFromEvent(event: SensorEvent) : SensorData

    private fun isValidTime(time: Calendar) : Boolean {
        return (time.timeInMillis - lastUpdate.timeInMillis) * 1000 >= timeIntervalInMicroseconds
    }

    fun isAvailable() : Boolean {
        return sensorManager.getSensorList(sensorId).isNotEmpty()
    }

    abstract fun getSensorInfo() : SensorInfo

    fun changeTimeInterval(timeIntervalInMicroseconds: Long) : State {
        this.timeIntervalInMicroseconds = timeIntervalInMicroseconds
        stopListener()
        startListener()
        return State.SUCCESS
    }

    protected fun getTimeIntervalInMicroseconds() : Long {
        return timeIntervalInMicroseconds
    }
}
