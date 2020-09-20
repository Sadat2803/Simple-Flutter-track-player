import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:volume/volume.dart';
import 'dart:async';
import 'soundTrack.dart';
void main() {runApp(new myApp());}


class myApp extends StatelessWidget
{
  @override
  Widget build (BuildContext context)
  {
    return new MaterialApp(
      title : "SADAT-Flutter-PLayer",
      theme : new ThemeData(
        primarySwatch: Colors.blue
      ),
      debugShowCheckedModeBanner: false,
      home : new Home()
    );
  }
}
class Home extends StatefulWidget
{
  @override
  State<StatefulWidget> createState()
  {
    return new _Home();
  }
}

class _Home extends State<Home>{

  List<SoundTrack> soundTracksList = [
    new SoundTrack("El Maikli - El fatiha", 'El muaikly', 'assets/img/m.png', 'assets/sound_tracks/m.mp3'),
    new SoundTrack("Al Afasy- El fatiha", 'Al Afasy', 'assets/img/a.png', 'assets/sound_tracks/a.mp3'),
    new SoundTrack("El Ghamidi - El fatiha", 'El Ghamidi', 'assets/img/g.png', 'assets/sound_tracks/g.mp3'),
  ];

  AudioPlayer audioPlayer ;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscription;

  SoundTrack currentSoundTrack;
  Duration position = new Duration(seconds: 0);
  Duration duration = new Duration(seconds: 30);
  PlayerState playerStatus = PlayerState.STOPPED;
  int index = 0;
  bool muted = false;
  int maxVol = 0;
  int currentVol = 0;
  @override
  void initState()
  {
    super.initState();
    currentSoundTrack = soundTracksList[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();
  }
  Widget build (BuildContext context)
  {
    return Scaffold(
     backgroundColor: Colors.white,
     appBar: new AppBar(
       title : new Text("SADAT Track Player"),
       backgroundColor: Colors.blueGrey,
       leading : new Icon(Icons.library_music),
       centerTitle: true,
       elevation: 30
     ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Container(
              width : 200,
              margin: EdgeInsets.only(top : 20),
              child: Image.asset(currentSoundTrack.imagePath),
            ),
            new Container(
              margin: EdgeInsets.only(top : 20),
              child: Text(
                currentSoundTrack.title,
                textScaleFactor: 2,
                style: TextStyle(color: Colors.black ),
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top : 10),
              child: Text(
                currentSoundTrack.author,
              ),
            )
          ],
        )
      ),
    );
  }
  Text textWithStyle(String data, double scale)
  {
    return new Text(data,
    textScaleFactor: scale,
    textAlign: TextAlign.center,
    style : new TextStyle(
        color : Colors.black,
        fontSize : 15
    ));
  }
  IconButton button(IconData )
  void configAudioPlayer()
  {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });
      if(position>= duration)
        {
          position = new Duration(seconds: 0);
          //PASSER A LA TRACK SUIVANTE
        }
    });
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING)
        {
          duration = audioPlayer.duration;
        }else if(state == AudioPlayerState.STOPPED)
          {
            setState(() {
              playerStatus = PlayerState.STOPPED;
            });
          }}, onError :(message)
                {
                  setState(()
                  {
                  playerStatus =  PlayerState.STOPPED;
                  duration = new Duration(seconds: 0);
                  position = new Duration(seconds: 0);
                  });
                }
    );
  }

  double getVolumePercentage()
  {
    return (currentVol/maxVol) * 100;
  }

  Future<void> initPlatformState() async
  {
   await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }
   updateVolume() async
  {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {
      
    });
  }

   setVolume(int i) async
  {
     await Volume.setVol(i);
  }

  Future play() async
  {
    await audioPlayer.play(currentSoundTrack.soundTrackUrl);
    setState(() {
      playerStatus = PlayerState.PLAYING;
    });
  }

  Future pause() async
  {
    await audioPlayer.pause();
    setState(() {
      playerStatus = PlayerState.PAUSED;
    });
  }

  Future mute() async
  {
    await audioPlayer.mute(!muted);
    setState(() {
      muted = !muted;
    });
  }
  void forward()
  {

  }
  void rewind()
  {

  }
  String fromDuration()
  {
    return duration.toString().split('.').first;
  }
}
enum ActionSoundTrack {
  PLAY,
  PAUSE,
  FORWAR,
  REWIND
}
enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}