#import "WatchConnectivityPlugin.h"
#if __has_include(<watch_connectivity/watch_connectivity-Swift.h>)
#import <watch_connectivity/watch_connectivity-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "watch_connectivity-Swift.h"
#endif

@implementation WatchConnectivityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWatchConnectivityPlugin registerWithRegistrar:registrar];
}
@end
