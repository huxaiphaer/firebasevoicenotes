import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playout/audio.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/player_state.dart';

class AudioWidget extends StatefulWidget {
  final String message;
  final PlayerState desiredState;

  @override
  _AudioWidgetState createState() => _AudioWidgetState();

  AudioWidget(this.message, this.desiredState);
}

class _AudioWidgetState extends State<AudioWidget> with PlayerObserver {
  AudioPlayer audioPlayer = new AudioPlayer();
  PlayerState audioPlayerState = PlayerState.STOPPED;
  Duration duration = Duration(milliseconds: 1);
  Duration currentPlaybackPosition = Duration.zero;
  bool _loading = false;
  Audio _audioPlayer;

  get isPlaying => audioPlayerState == PlayerState.PLAYING;

  get isPaused =>
      audioPlayerState == PlayerState.PAUSED ||
      audioPlayerState == PlayerState.STOPPED;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText => currentPlaybackPosition != null
      ? currentPlaybackPosition.toString().split('.').first
      : '';

  @override
  void initState() {
    super.initState();
    _audioPlayer = Audio.instance();
    listenForAudioPlayerEvents();
  }

  @override
  void didUpdateWidget(AudioWidget oldWidget) {
    // TODO: implement didUpdateWidget

    if (oldWidget.desiredState != widget.desiredState) {
      _onDesiredStateChanged(oldWidget);
    } else if (oldWidget.message != widget.message) {
      play(widget.message);
    }
    super.didUpdateWidget(oldWidget);
  }

  /// The [desiredState] flag has changed so need to update playback to
  /// reflect the new state.
  void _onDesiredStateChanged(AudioWidget oldWidget) async {
    switch (widget.desiredState) {
      case PlayerState.PLAYING:
        play(widget.message);
        break;
      case PlayerState.PAUSED:
        pause();
        break;
      case PlayerState.STOPPED:
        pause();
        break;
    }
  }

  @override
  void onPlay() {
    setState(() {
      audioPlayerState = PlayerState.PLAYING;
      _loading = false;
    });
  }

  @override
  void onPause() {
    setState(() {
      audioPlayerState = PlayerState.PAUSED;
    });
  }

  @override
  void onComplete() {
    setState(() {
      audioPlayerState = PlayerState.PAUSED;
      currentPlaybackPosition = Duration.zero;
    });
  }

  @override
  void onTime(int position) {
    setState(() {
      currentPlaybackPosition = Duration(seconds: position);
    });
  }

  @override
  void onSeek(int position, double offset) {
    super.onSeek(position, offset);
  }

  @override
  void onDuration(int duration) {
    if (duration <= 0) {
      setState(() {});
    } else {
      setState(() {
        this.duration = Duration(milliseconds: duration);
      });
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _audioPlayer.dispose();
      stop();
    }
    super.dispose();
  }

  Future play(url) async {
    setState(() {
      _loading = true;
    });
    await _audioPlayer.play(url,
        title: "voice note",
        position: currentPlaybackPosition,
        isLiveStream: false);
  }

  // Request audio pause
  Future<void> pause() async {
    _audioPlayer.pause();
    setState(() => audioPlayerState = PlayerState.PAUSED);
  }

  // Request audio stop. this will also clear lock screen controls
  Future<void> stop() async {
    _audioPlayer.reset();

    setState(() {
      audioPlayerState = PlayerState.STOPPED;
      currentPlaybackPosition = Duration.zero;
    });
  }

  // Seek to a point in seconds
  Future<void> seekTo(double milliseconds) async {
    setState(() {
      currentPlaybackPosition = Duration(milliseconds: milliseconds.toInt());
    });
    _audioPlayer.seekTo(milliseconds / 1000);
  }

  @override
  Widget build(BuildContext context) {
    print("-- $isPlaying");
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: IconButton(
                onPressed: () {
                  if (isPlaying) {
                    pause();
                  } else {
                    play(widget.message);
                  }
                },
                icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow)),
          ),
          duration != null
              ? Slider(
                  value: currentPlaybackPosition?.inMilliseconds?.toDouble() ??
                      0.0,
                  onChanged: seekTo,
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble(),
                  activeColor: Colors.red[500],
                )
              : Slider(
                  value: 0.0,
                  activeColor: Colors.red[500],
                  inactiveColor: Colors.red[500],
                )
        ],
      ),
    );
  }
}
