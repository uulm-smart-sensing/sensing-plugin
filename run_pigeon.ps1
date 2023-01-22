Write-Output "Generating Pigeon code..."
flutter pub run pigeon `
    --input pigeons/api_sensor_manager.dart `
    --dart_out lib/src/generated/api_sensor_manager.dart `
    --objc_header_out ios/Classes/Generated/ApiSensorManager.h `
    --objc_source_out ios/Classes/Generated/ApiSensorManager.m `
    --objc_prefix FLT `
    --java_out android/src/main/kotlin/de/uniulm/sensing_plugin/generated/ApiSensorManager.java `
    --java_package "de.uniulm.sensing_plugin.generated"
