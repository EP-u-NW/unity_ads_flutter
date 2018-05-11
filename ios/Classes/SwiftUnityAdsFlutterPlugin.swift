import Flutter
import UIKit
import UnityAds
    
public class SwiftUnityAdsFlutterPlugin: NSObject, FlutterPlugin,UnityAdsDelegate {
    
    let mChannel: FlutterMethodChannel;
    var mViewController: UIViewController?;
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "eu.epnw.unity_ads_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftUnityAdsFlutterPlugin(methodChannel: channel);
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    init(methodChannel: FlutterMethodChannel){
        self.mViewController = nil;
        self.mChannel  = methodChannel;
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if self.mViewController == nil{
            self.mViewController = (UIApplication.shared.keyWindow?.rootViewController)!;
        }
        var args: Dictionary<String,Any> = [:];
        if call.arguments != nil{
            args = (call.arguments as! NSDictionary) as! Dictionary<String,Any>
        }
        if (call.method == "getDebugMode") {
            result(UnityAds.getDebugMode());
        } else if(call.method == "getDefaultPlacementState") {
            result(UnityAds.getPlacementState().rawValue);
        } else if(call.method == "getPlacementState" && args["placementId"] != nil) {
            result(UnityAds.getPlacementState(args["placementId"] as! String).rawValue);
        } else if(call.method == "getVersion"){
            result(UnityAds.getVersion());
        } else if(call.method == "initialize" && args["gameId"] != nil && args["testMode"] != nil){
            UnityAds.initialize(args["gameId"] as! String, delegate: self, testMode: args["testMode"] as! Bool)
            result(nil);
        } else if(call.method == "isInitialized"){
            result(UnityAds.isInitialized());
        } else if(call.method == "isDefaultReady"){
            result(UnityAds.isReady());
        } else if(call.method == "isReady" && args["placementId"] != nil){
            result(UnityAds.isReady(args["placementId"] as! String));
        } else if(call.method == "isSupported"){
            result(UnityAds.isSupported());
        } else if(call.method == "setDebugMode" && args["debugMode"] != nil){
            UnityAds.setDebugMode(args["debugMode"] as! Bool);
            result(nil);
        } else if(call.method == "showDefault"){
            UnityAds.show(self.mViewController!);
            result(nil);
        } else if(call.method == "show" && args["placementId"] != nil){
            UnityAds.show(self.mViewController!, placementId: args["placementId"] as! String);
            result(nil);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
    public func unityAdsReady(_ placementId: String) {
        self.mChannel.invokeMethod("onUnityAdsReady", arguments: placementId);
    }
  
    public func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
        let dictionary: NSDictionary = ["error" : error.rawValue,"message": message];
        self.mChannel.invokeMethod("onUnityAdsError", arguments: dictionary);
    }
    
    public func unityAdsDidStart(_ placementId: String) {
        self.mChannel.invokeMethod("onUnityAdsStart", arguments: placementId);
    }
    
    public func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        let dictionary: NSDictionary = ["placementId" : placementId, "result":state.rawValue];
        self.mChannel.invokeMethod("onUnityAdsFinish", arguments: dictionary);
    }
    
}
