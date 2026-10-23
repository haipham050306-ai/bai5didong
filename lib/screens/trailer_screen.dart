import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({super.key, required this.url});
  final String url;
  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late final VideoPlayerController _controller;
  Object? _error;
  @override
  void initState() { super.initState(); _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) { if (mounted) setState(() {}); _controller.play(); }).catchError((e) { if (mounted) setState(() => _error = e); }); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Trailer')),
    body: Center(child: _error != null ? Padding(padding: const EdgeInsets.all(20), child: Text('Không phát được video: $_error', textAlign: TextAlign.center)) : !_controller.value.isInitialized ? const CircularProgressIndicator() : AspectRatio(aspectRatio: _controller.value.aspectRatio, child: Stack(alignment: Alignment.bottomCenter, children: [VideoPlayer(_controller), VideoProgressIndicator(_controller, allowScrubbing: true), Align(alignment: Alignment.center, child: IconButton.filled(onPressed: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()), icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)))]))));
}
