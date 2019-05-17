import 'package:flutter/material.dart';
import "package:intl/intl.dart" show DateFormat;
import "package:intl/date_symbol_data_local.dart";
import "package:flutter_sound/flutter_sound.dart";
import "dart:io";
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp>
{
  FlutterSound flutterSound;

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription _recordSub;
  StreamSubscription _playerSub;

  String _recordText = "00:00:00";
  String _playerText = "00:00:00";

  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    initializeDateFormatting();
  }

  void startRecord() async {
    try{
      String path = await flutterSound.startRecorder(null, bitRate: 4400);
      print("startRecord $path");

      _recordSub = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());       
        setState(() {
            _isRecording = true;
            this._recordText = DateFormat('mm:ss:SS', 'en_US').format(date);
        });        
      });
    }
    catch(error){
      print("startRecord error $error");
    }
  }

  void stopRecord() async {
    try{
      String result = await flutterSound.stopRecorder();
      print("stopRecorder: $result");

      if (_recordSub != null) {
        _recordSub.cancel();
        _recordSub = null;
      }

      setState(() {
         _isRecording = false;
      });
    }
    catch(error){
      print("stopRecord error $error");
    }
  }

  void startPlayer() async {
    try{
      String path = await flutterSound.startPlayer(null);
      print('startPlayer: $path');

      _playerSub = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());       
          setState(() {
              _isPlaying = true;
              this._playerText = DateFormat('mm:ss:SS', 'en_US').format(date);
          }); 
        }
      });
    }
    catch(error){
      print("startPlayer error $error");
    }
  }

  void stopPlayer() async {
    try{
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSub != null) {
        _playerSub.cancel();
        _playerSub = null;
      }

      setState(() {
         _isPlaying = false;
      });
    }
    catch(error){
      print("stopPlayer error $error");
       setState(() {
         _isPlaying = false;
      });
    }
  }

  Icon getIconRecord() {
    if(!_isRecording)
      return Icon(Icons.mic, size: 32.0,);
    else
      return Icon(Icons.stop, size: 32.0,);
  }

  Icon getIconPlayer() {
    if(!_isPlaying)
      return Icon(Icons.play_arrow, size: 32.0,);
    else
      return Icon(Icons.stop, size: 32.0,);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: AppBar(title: Text("Sound Recorder")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(_recordText, style: TextStyle(fontSize: 22)),
                IconButton(icon: getIconRecord(), onPressed: () => !_isRecording ? startRecord() : stopRecord()),
                Text(_playerText, style: TextStyle(fontSize: 22)),
                IconButton(icon: getIconPlayer(), onPressed: () => !_isPlaying ? startPlayer() : stopPlayer()),
              ],
            ),
          ),
        ),
      )

    );
  }  
}