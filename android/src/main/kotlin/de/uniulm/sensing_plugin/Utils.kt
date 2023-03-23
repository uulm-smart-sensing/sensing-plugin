package de.uniulm.sensing_plugin

import android.hardware.SensorManager
import de.uniulm.sensing_plugin.generated.ApiSensorManager

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

fun getAccuracyEnumFromValue(accuracyValue: Int): ApiSensorManager.SensorAccuracy =
    when (accuracyValue) {
        SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> ApiSensorManager.SensorAccuracy.HIGH
        SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> ApiSensorManager.SensorAccuracy.MEDIUM
        SensorManager.SENSOR_STATUS_ACCURACY_LOW -> ApiSensorManager.SensorAccuracy.LOW
        SensorManager.SENSOR_STATUS_UNRELIABLE -> ApiSensorManager.SensorAccuracy.UNRELIABLE
        SensorManager.SENSOR_STATUS_NO_CONTACT -> ApiSensorManager.SensorAccuracy.NO_CONTACT
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
