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
      title : "إقرأ",
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
    new SoundTrack("El Maikli - El fatiha", 'El muaikly', 'assets/img/m.png', 'https://server12.mp3quran.net/maher/001.mp3'),
    new SoundTrack("Al Afasy- El fatiha", 'Al Afasy', 'assets/img/a.png', 'https://server8.mp3quran.net/afs/001.mp3'),
    new SoundTrack("El Ghamidi - El fatiha", 'El Ghamidi', 'assets/img/g.png', 'https://server7.mp3quran.net/s_gmd/001.mp3'),
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
    print("hi");
    super.initState();
    currentSoundTrack = soundTracksList[index];
    audioPlayer = new AudioPlayer();
    duration = audioPlayer.duration;
    configAudioPlayer();
    initPlatformState();
    updateVolume();
  }
  @override
  Widget build (BuildContext context)
  {double width = MediaQuery.of(context).size.width;
    return Scaffold(

     backgroundColor: Colors.white,
     appBar: new AppBar(
       title : new Text("إقرأ"),
       backgroundColor: Colors.green,
       leading : new Icon(Icons.library_music),
       centerTitle: true,
       elevation: 30,
     ),
      body:  SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Container(
                margin: EdgeInsets.only(top : 20),
                child: Image.asset(currentSoundTrack.imagePath,scale: 1),
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
              ),

              new Container(
                height: width / 5,
                margin : EdgeInsets.only(left: 10.0, right : 10.0 ),
                child : new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                    new IconButton(
                        icon: (playerStatus != PlayerState.PLAYING ) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause),
                        onPressed : (playerStatus != PlayerState.PLAYING ) ? play : pause
                    ),
                    new IconButton(icon: (!muted) ? new Icon(Icons.headset) : new Icon(Icons.headset_off),
                        onPressed: mute),
                    new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward)
                  ],
                )

              ),
              new Container(
                  margin : EdgeInsets.only(left: 20.0, right : 20.0 ),
                  child : new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textWithStyle(fromDuration(position), 0.8),
                      textWithStyle(fromDuration(duration), 0.8),
                    ],
                  )
              ),
              new Container(
                  margin : EdgeInsets.only(left: 20.0, right : 20.0 ),
                  child : new Slider(
                    min: 0.0,
                    max : duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    inactiveColor: Colors.grey[500],
                    activeColor: Colors.lightGreen,
                    onChanged: (double d)
                    {
                      setState(() {
                        audioPlayer.seek(d);
                      });
                    },
                  )
              ),
              new Container(
                height: width /5,
                margin: EdgeInsets.only(left: 5.0,right: 5.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new IconButton(
                        icon: new Icon(Icons.remove),
                        iconSize: 18,
                        onPressed: () {
                          if (!muted) {
                            if (currentVol - 1 >= 0) {
                              setState(() {
                                currentVol = currentVol - 1;
                              });
                              setVolume(currentVol);
                            }
                            else {
                              setVolume(0);
                            }
                          }
                        }
                    ),
                    new Text((muted) ? 'mute' : getVolumePercentage().toString().split('.').first + '%'),
                    new IconButton(
                        icon: new Icon(Icons.add),
                        iconSize: 18,
                        onPressed: (){
                            if(!muted)
                            {
                              if(currentVol + 1 <= maxVol)
                                {
                                  setState(() { currentVol = currentVol + 1;});
                                  setVolume(currentVol);
                                }
                              else
                                {
                                  setVolume(maxVol);
                                }
                            }
                          }
                    )
                  ],
                ),
              )
            ],
          )
        ),
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

  IconButton bouton(IconData icon, double size, ActionSoundTrack action)
  {
    new IconButton(
        icon: new Icon(icon),
        iconSize: size,
        color: Colors.white,
        onPressed: ()
        {
          switch(action)
          {
            case ActionSoundTrack.PLAY:
              play();
              break;
            case ActionSoundTrack.PAUSE:
              pause();
              break;
          }
        }
    );
  }
  void configAudioPlayer()
  {
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });
      if(position>= duration)
        {
            position = new Duration(seconds: 0);
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
    setState(() {
      currentVol = ((maxVol * 75.0 )/ 100.0).toInt();
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
    index++;
    if(index >= soundTracksList.length)
      {
        index = 0;
      }
      audioPlayer.stop();
      setState(() {
        currentSoundTrack = soundTracksList[index];
      });
      configAudioPlayer();
      play();
  }
  void rewind()
  {
    index--;
    if(index<0)
    {
      index = soundTracksList.length - 1 ;
    }
    audioPlayer.stop();
    currentSoundTrack = soundTracksList[index];
    configAudioPlayer();
    play();
  }

  String fromDuration(duration)
  {
    return duration.toString().split('.').first;
  }
}
enum ActionSoundTrack {
  PLAY,
  PAUSE,
  FORWARD,
  REWIND
}
enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}