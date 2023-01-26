#import "SensorDemoPlugin.h"
#if __has_include(<sensor_demo/sensor_demo-Swift.h>)
#import <sensor_demo/sensor_demo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sensor_demo-Swift.h"
#endif

@implementation SensorDemoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SensorDemoPlugin registerWithRegistrar:registrar];
}
@end
