import 'dart:async';
import 'package:audio_component/audio_component.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'utils/permission.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestAudioPermissions();

  await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.myapp.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioPlayerScreen(),
    );
  }
}

/// Audio Player Handler for background playback
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        stop();
      }
    });
  }

  @override
  Future<void> _play(String url) async {
    await _player.setAsset(url);
    _player.play();
  }

  @override
  Future<void> stop() async => await _player.stop();

  @override
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> seek(Duration position) async => await _player.seek(position);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  double get volume => _player.volume;
  Future<void> setVolume(double value) async => await _player.setVolume(value);
}

/// Main Audio Player Screen
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler();
  double currentPosition = 0;
  double maxDuration = 100;
  bool isPlaying = false;
  bool isLooping = false;
  double volume = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    String url = 'assets/audio/SoundHelix-Song-1.mp3';
    await _audioHandler._play(url);
    setState(() {
      isPlaying = true;
    });

    _audioHandler.positionStream.listen((position) {
      setState(() {
        currentPosition = position.inSeconds.toDouble();
      });
    });

    maxDuration = (_audioHandler._player.duration)?.inSeconds.toDouble() ?? 0;
    setState(() {});
  }

  Future<void> _play() async {
    await _audioHandler._play('assets/audio/SoundHelix-Song-1.mp3');
    setState(() => isPlaying = true);
  }

  Future<void> _pause() async {
    await _audioHandler.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _stop() async {
    await _audioHandler.stop();
    setState(() {
      isPlaying = false;
      currentPosition = 0;
    });
  }

  Future<void> _seekTo(double value) async {
    await _audioHandler.seek(Duration(seconds: value.toInt()));
    setState(() => currentPosition = value);
  }

  Future<void> _changeVolume(double value) async {
    await _audioHandler.setVolume(value);
    setState(() => volume = value);
  }

  Future<void> _toggleLooping() async {
    isLooping = !isLooping;
    await _audioHandler._player.setLoopMode(
      isLooping ? LoopMode.one : LoopMode.off,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AlbumArt(albumImage: 'assets/image/beethoven.jpeg'),
          SongInfo(
            title1: 'First Title For Song',
            title2: 'Description For Song And this small title',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(currentPosition.toInt().toString()),
              Expanded(
                child: Slider(
                  value: currentPosition,
                  min: 0,
                  max: maxDuration,
                  onChanged: _seekTo,
                ),
              ),
              Text(maxDuration.toInt().toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 56,
                ),
                onPressed: isPlaying ? _pause : _play,
              ),
              IconButton(
                icon: const Icon(Icons.stop, size: 56),
                onPressed: _stop,
              ),
              IconButton(
                icon: Icon(
                  isLooping ? Icons.repeat_one : Icons.repeat,
                  size: 56,
                ),
                onPressed: _toggleLooping,
              ),
            ],
          ),
          Volume(volume: volume, onChanged: _changeVolume),
        ],
      ),
    );
  }
}
