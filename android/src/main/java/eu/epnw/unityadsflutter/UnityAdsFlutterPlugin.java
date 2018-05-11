package eu.epnw.unityadsflutter;

import android.app.Activity;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.unity3d.ads.IUnityAdsListener;
import com.unity3d.ads.UnityAds;

import java.util.HashMap;
import java.util.Map;

/**
 * UnityAdsFlutterPlugin
 */
public class UnityAdsFlutterPlugin implements MethodCallHandler, IUnityAdsListener {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "eu.epnw.unity_ads_flutter");
    channel.setMethodCallHandler(new UnityAdsFlutterPlugin(registrar.activity(),channel));
  }

  private final Activity mActivity;
  private final MethodChannel mChannel;

  private UnityAdsFlutterPlugin(Activity activity,MethodChannel channel){
    this.mActivity=activity;
    this.mChannel=channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getDebugMode")) {
      result.success(UnityAds.getDebugMode());
    } else if(call.method.equals("getDefaultPlacementState")) {
      result.success(UnityAds.getPlacementState().ordinal());
    } else if(call.method.equals("getPlacementState") && call.hasArgument("placementId")) {
      result.success(UnityAds.getPlacementState(call.<String>argument("placementId")).ordinal());
    } else if(call.method.equals("getVersion")){
      result.success(UnityAds.getVersion());
    } else if(call.method.equals("initialize") && call.hasArgument("gameId") && call.hasArgument("testMode")){
      UnityAds.initialize(mActivity,call.<String>argument("gameId"),this,call.<Boolean>argument("testMode"));
      result.success(null);
    } else if(call.method.equals("isInitialized")){
      result.success(UnityAds.isInitialized());
    } else if(call.method.equals("isDefaultReady")){
      result.success(UnityAds.isReady());
    } else if(call.method.equals("isReady") && call.hasArgument("placementId")){
      result.success(UnityAds.isReady(call.<String>argument("placementId")));
    } else if(call.method.equals("isSupported")){
      result.success(UnityAds.isSupported());
    } else if(call.method.equals("setDebugMode") && call.hasArgument("debugMode")){
      UnityAds.setDebugMode(call.<Boolean>argument("debugMode"));
      result.success(null);
    } else if(call.method.equals("showDefault")){
      UnityAds.show(mActivity);
      result.success(null);
    } else if(call.method.equals("show") && call.hasArgument("placementId")){
      UnityAds.show(mActivity,call.<String>argument("placementId"));
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onUnityAdsReady(String placementId) {
    mChannel.invokeMethod("onUnityAdsReady",placementId);
  }

  @Override
  public void onUnityAdsStart(String placementId) {
    mChannel.invokeMethod("onUnityAdsStart",placementId);
  }

  @Override
  public void onUnityAdsFinish(String placementId, UnityAds.FinishState result) {
    Map<String,Object> arguments=new HashMap<String,Object>();
    arguments.put("placementId",placementId);
    arguments.put("result",result.ordinal());
    mChannel.invokeMethod("onUnityAdsFinish",arguments);
  }

  @Override
  public void onUnityAdsError(UnityAds.UnityAdsError error, String message) {
    Map<String,Object> arguments=new HashMap<String,Object>();
    arguments.put("error",error.ordinal());
    arguments.put("message",message);
    mChannel.invokeMethod("onUnityAdsError",arguments);
  }
}
