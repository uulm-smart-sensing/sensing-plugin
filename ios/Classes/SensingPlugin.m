#import "SensingPlugin.h"
#if __has_include(<sensing_plugin/sensing_plugin-Swift.h>)
#import <sensing_plugin/sensing_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sensing_plugin-Swift.h"
#endif

@implementation SensingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SensorManager registerWithRegistrar:registrar];
}
@end
