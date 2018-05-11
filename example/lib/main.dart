import 'package:flutter/material.dart';
import 'package:unity_ads_flutter/unity_ads_flutter.dart';

//TODO use your own ids from the Unity Ads Dashboard
const String videoPlacementId='video';
const String gameIdAndroid='1790451';
const String gameIdIOS='1790452';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with UnityAdsListener{

  UnityAdsError _error;
  String _errorMessage;
  bool _ready;

  @override
  initState() {
    UnityAdsFlutter.initialize(gameIdAndroid, gameIdIOS, this, true);
    _ready = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
      if(_error!=null){
        body = new Center(
            child: new Text('$_error: $_errorMessage')
        );
      } else if(_ready){
        body=new Center(
            child:new RaisedButton(
                onPressed: () {
                  setState((){
                    _ready=false;
                  });
                  UnityAdsFlutter.show('video');
                },
                child: const Text('Ready')
            )
        );
      } else {
        body = new Center(
            child:const Text('Waiting for an ad...')
        );
      }
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Unity Ads Flutter Example'),
        ),
        body: body,
      ),
    );
  }

  @override
  void onUnityAdsError(UnityAdsError error, String message) {
    print('$error occurred: $message');
    setState((){
      _error=error;
      _errorMessage=message;
    });
  }

  @override
  void onUnityAdsFinish(String placementId, FinishState result) {
    print('Finished $placementId with $result');
  }

  @override
  void onUnityAdsReady(String placementId) {
    print('Ready: $placementId');
    if (placementId == videoPlacementId){
      setState(() {
        _ready=true;
      });
    }
  }

  @override
  void onUnityAdsStart(String placementId) {
    print('Start: $placementId');
    if(placementId == videoPlacementId){
      setState(() {
        _ready = false;
      });
    }
  }
}
