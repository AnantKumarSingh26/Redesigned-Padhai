import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // Download and cache the video
    final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);

    // Initialize the video player with the cached file
    _videoPlayerController = VideoPlayerController.file(file)
      ..setLooping(true); // Enable looping for seamless playback
    await _videoPlayerController.initialize();
    _videoPlayerController
        .play(); // Start playing immediately after initialization
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child:
            _isInitialized && _videoPlayerController.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
                : const CircularProgressIndicator(), // Show a loader until initialized
      ),
      floatingActionButton:
          _isInitialized && _videoPlayerController.value.isInitialized
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_videoPlayerController.value.isPlaying) {
                      _videoPlayerController.pause();
                    } else {
                      _videoPlayerController.play();
                    }
                  });
                },
                child: Icon(
                  _videoPlayerController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              )
              : null, // Hide FAB if not initialized
    );
  }
}
