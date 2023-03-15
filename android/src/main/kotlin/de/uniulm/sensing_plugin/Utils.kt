package de.uniulm.sensing_plugin

fun screamingSnakeCaseToCamelCase(text: String): String =
    text.split("_").map { word -> word.lowercase() }
        .mapIndexed {
            index, word -> if (index > 0) word.replaceFirstChar { it.titlecase() } else word
        }
        .joinToString("")
