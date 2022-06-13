#import "WatchConnectivityGarminPlugin.h"
#if __has_include(<watch_connectivity_garmin/watch_connectivity_garmin-Swift.h>)
#import <watch_connectivity_garmin/watch_connectivity_garmin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "watch_connectivity_garmin-Swift.h"
#endif

@implementation WatchConnectivityGarminPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWatchConnectivityGarminPlugin registerWithRegistrar:registrar];
}
@end
