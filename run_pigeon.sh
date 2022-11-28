flutter pub run pigeon \
    --input pigeons/messages.dart \
    --dart_out lib/generated/messages.dart \
    --objc_header_out ios/Classes/generated/AppUsageApi.h \
    --objc_source_out ios/Classes/generated/AppUsageApi.m \
    --objc_prefix FLT \
    --java_out android/src/main/kotlin/de/uniulm/sensor_demo/generated/Messages.java \
    --java_package "de.uniulm.sensor_demo.generated"
