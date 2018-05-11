import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

class UnityAdsFlutter {
  static const MethodChannel _channel = const MethodChannel('eu.epnw.unity_ads_flutter');

  static UnityAdsListener _listener;

  static Future<bool> getDebugMode() async {
    bool debug=await _channel.invokeMethod('getDebugMode');
    return debug;
  }
  static UnityAdsListener getListener() {
    return _listener;
  }
  static Future<PlacementState> getDefaultPlacementState() async {
    int placementState=await _channel.invokeMethod('getDefaultPlacementState');
    return PlacementState.values[placementState];
  }
  static Future<PlacementState> getPlacementState(String placementId) async {
    int placementState=await _channel.invokeMethod('getPlacementState',{'placementId':placementId});
    return PlacementState.values[placementState];
  }
  static Future<String> getVersion() async {
    String version=await _channel.invokeMethod('getVersion');
    return version;
  }
  static Future<Null> initialize(final String gameIdAndroid,final String gameIdIOS, final UnityAdsListener listener, final bool testMode) async {
    String gameId;
    if(Platform.isAndroid){
      gameId=gameIdAndroid;
    } else if(Platform.isIOS){
      gameId=gameIdIOS;
    } else {
      throw new UnsupportedError('Unsupported Platform! Only Android and IOS are supported!');
    }
    _listener=listener;
    _channel.setMethodCallHandler(_listener._handle);
    await _channel.invokeMethod('initialize',{'gameId':gameId,'testMode':testMode});
  }
  static Future<bool> isInitialized() async {
    bool initialized=await _channel.invokeMethod('isInitialized');
    return initialized;
  }
  static Future<bool> isDefaultReady() async {
    bool ready=await _channel.invokeMethod('isDefaultReady');
    return ready;
  }
  static Future<bool> isReady(String placementId) async {
    bool ready=await _channel.invokeMethod('isReady',{'placementId':placementId});
    return ready;
  }
  static Future<bool> isSupported() async {
    bool supported=await _channel.invokeMethod('isSupported');
    return supported;
  }
  static Future<Null> setDebugMode(bool debugMode) async {
    await _channel.invokeMethod('setDebugMode',{'debugMode':debugMode});
  }
  static void setListener(UnityAdsListener listener) {
    _listener=listener;
    _channel.setMethodCallHandler(_listener._handle);
  }
  static Future<Null> showDefault() async{
    await _channel.invokeMethod('showDefault');
  }
  static Future<Null> show(final String placementId) async{
    await _channel.invokeMethod('show',{'placementId':placementId});
  }

}

//An enumeration for the completion state of an ad.
enum FinishState {
  //  A state that indicates that the ad did not successfully display.
  error,
  //  A state that indicates that the user skipped the ad.
  skipped,
  //  A state that indicates that the ad was played entirely.
  completed
}

// Describes state of Unity Ads placements. All placement states other than READY imply that placement is not currently ready to show ads.
enum PlacementState {
  // Placement is ready to show ads. You can call show method and ad unit will open.
  ready,
  // Current placement state is not available. SDK is not initialized or this placement has not been configured in Unity Ads admin tools.
  not_available,
  // Placement is disabled. Placement can be enabled via Unity Ads admin tools.
  disabled,
  // Placement is not yet ready but it will be ready in the future. Most likely reason is caching.
  waiting,
  // Placement is properly configured but there are currently no ads available for the placement.
  no_fill
}
enum UnityAdsError {
  not_initialized,
  initialize_failed,
  invalid_argument,
  video_player_error,
  init_sanity_check_fail,
  ad_blocker_detected,
  file_io_error,
  device_id_error,
  show_error,
  internal_error
}


abstract class UnityAdsListener {

  Future<Null> _handle(MethodCall methodCall) async {
    if(methodCall.method=='onUnityAdsError'){
      onUnityAdsError(UnityAdsError.values[methodCall.arguments['error']],methodCall.arguments['message']);
    } else if(methodCall.method=='onUnityAdsFinish'){
      onUnityAdsFinish(methodCall.arguments['placementId'], FinishState.values[methodCall.arguments['result']]);
    } else if(methodCall.method=='onUnityAdsReady'){
      onUnityAdsReady(methodCall.arguments);
    } else if(methodCall.method=='onUnityAdsStart'){
      onUnityAdsStart(methodCall.arguments);
    }
  }

  void onUnityAdsError(UnityAdsError error, String message);

  void onUnityAdsFinish(String placementId, FinishState result);

  void onUnityAdsReady(String placementId);

  void onUnityAdsStart(String placementId);
}