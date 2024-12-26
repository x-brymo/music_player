import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  Timer? _timer; // Timer for automatic stop
  String _currentFormat = 'mp3'; // To toggle between MP3 and WAV

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.closePlayer();
    super.dispose();
  }

  /// Toggle between MP3 and WAV
  void _toggleFormat() {
    setState(() {
      _currentFormat = _currentFormat == 'mp3' ? 'wav' : 'mp3';
    });
  }

  /// Play or Pause Audio from assets
  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _player.stopPlayer();
        _timer?.cancel();
      } else {
        String assetPath =
            'assets/audio/SoundHelix-Song-1.mp3'; // Use a WAV file path

        await _player.startPlayer(
          fromURI: assetPath, // Play from asset
          codec: Codec.mp3 , 
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
            _timer?.cancel();
          },
        );

        // Start a timer to stop after 10 seconds
        _timer = Timer(const Duration(seconds: 10), () async {
          await _player.stopPlayer();
          setState(() {
            _isPlaying = false;
          });
        });
      }

      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Error during playback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Playing Format: $_currentFormat',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          IconButton(
            iconSize: 100,
            icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
            onPressed: _playPause,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleFormat,
            child: const Text('Switch Format (MP3/WAV)'),
          ),
        ],
      ),
    );
  }
}
