import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';



class TimerPage extends StatefulWidget {
  final  restTime;
  const TimerPage({required this.restTime});
  @override
  _TimerPageState createState() => _TimerPageState(restTime);
}

class _TimerPageState extends State<TimerPage> {
  int restTime;
  _TimerPageState( this.restTime);
  AudioPlayer? _player;
  final AudioCache audioCache = AudioCache();


  bool _isActive = false;
  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (restTime > 0) {
          restTime--;
        } else {
          _timer.cancel();
          print('Timer reached zero!');
          play();
        }
      });
    });
  }
  void play() {
    final player = _player = AudioPlayer();
    player.play(AssetSource('audios/attention.mp3'));
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      restTime = widget.restTime;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // bool _showStartBtn = true;
  // bool _showStopResetBtn = false;
  //
  // void startTimer() {
  //   setState(() {
  //     _showStartBtn = false;
  //     _showStopResetBtn = true;
  //   });


  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.grey[850],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Rest Time', style: TextStyle(fontSize: 20, color: Colors.white),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$restTime seconds',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _isActive ? Colors.red : Color(0xff9b1616),
                  ),
                  child: Text(_isActive ? 'Stop' : 'Start' ,style: TextStyle(fontSize: 20),),
                  onPressed: () {
                    setState(() {
                      _isActive = !_isActive;
                      if (_isActive) {
                        startTimer();
                      } else {
                        stopTimer();
                      }
                    });
                  },
                ),
                SizedBox(width: 20),
                Visibility(
                  visible: !_isActive,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff9b1616),
                    ),
                    child: Text('Reset' ,style: TextStyle(fontSize: 20),),
                    onPressed: () {
                      setState(() {
                        resetTimer();
                      });
                    },
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}


// void main() {
//   runApp(MaterialApp(
//     home: TimerPage(),
//   ));
// }
