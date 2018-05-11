#import "UnityAdsFlutterPlugin.h"
#import <unity_ads_flutter/unity_ads_flutter-Swift.h>

@implementation UnityAdsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUnityAdsFlutterPlugin registerWithRegistrar:registrar];
}
@end
