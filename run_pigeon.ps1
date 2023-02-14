Write-Output "Generating Pigeon code..."
flutter pub run pigeon `
    --input pigeons/api_sensor_manager.dart `
    --dart_out lib/src/generated/api_sensor_manager.dart `
    --experimental_swift_out ios/Classes/Generated/ApiSensorManager.swift `
    --java_out android/src/main/kotlin/de/uniulm/sensing_plugin/generated/ApiSensorManager.java `
    --java_package "de.uniulm.sensing_plugin.generated"
