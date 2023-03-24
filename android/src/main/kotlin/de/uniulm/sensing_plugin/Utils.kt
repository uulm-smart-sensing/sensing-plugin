package de.uniulm.sensing_plugin

import android.hardware.SensorEvent
import android.hardware.SensorManager
import android.os.SystemClock
import de.uniulm.sensing_plugin.generated.ApiSensorManager.SensorAccuracy

/**
 * Converts a String in SCREAMING_SNAKE_CASE to camelCase.
 *
 * Example: EXAMPLE_TEXT -> exampleText
 */
fun screamingSnakeCaseToCamelCase(text: String): String =
    text
        .split("_")
        .map { word -> word.lowercase() }
        .mapIndexed { index, word ->
            if (index > 0) word.replaceFirstChar { it.titlecase() } else word
        }
        .joinToString("")

fun getAccuracyEnumFromValue(accuracyValue: Int): SensorAccuracy =
    when (accuracyValue) {
        SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> SensorAccuracy.HIGH
        SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> SensorAccuracy.MEDIUM
        SensorManager.SENSOR_STATUS_ACCURACY_LOW -> SensorAccuracy.LOW
        SensorManager.SENSOR_STATUS_UNRELIABLE -> SensorAccuracy.UNRELIABLE
        SensorManager.SENSOR_STATUS_NO_CONTACT -> SensorAccuracy.NO_CONTACT
        else -> { throw IllegalArgumentException("Unexpected accuracy value '$accuracyValue'") }
    }

/**
 * Calculates the decimal precision from the passed [resolution].
 *
 * Precision is the number of decimal places of a value to which the value is accurate.
 * Example: 0.03456 -> 2
 * If the resolution is less than 1E-12 the precision is capped at 12 decimal places.
 */
fun getPrecisionFromResolution(resolution: Float): Long {
    if (resolution < 1E-12) {
        return 12
    }
    var precision = 0L
    var res = resolution
    while (res < 1) {
        precision++
        res *= 10
    }
    return precision
}

/**
 * Converts the timestamp of a [SensorEvent] to Unix timestamp with a precision in microseconds.
 *
 * [SensorEvent.timestamp] is the timestamp since boot of the device and needs to be synced with
 * the timestamp of the boot to get the actual Unix timestamp.
 *
 * For more information:
 * [StackOverflow](https://stackoverflow.com/questions/3498006/sensorevent-timestamp-to-absolute-utc-timestamp)
 */
fun convertSensorEventTimestampToUnixTimestamp(eventTimeInNanoseconds: Long): Long {
    // SystemClock.elapsedRealtimeNanos() returns the elapsed time since the device was booted.
    val bootTimestampInMicroseconds =
        (System.currentTimeMillis() * 1000) - (SystemClock.elapsedRealtimeNanos() / 1000)
    // Add the event timestamp to the boot timestamp to get the unix timestamp of the event
    return bootTimestampInMicroseconds + (eventTimeInNanoseconds / 1000)
}
