import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RTCVideoRenderer? _localRenderer;

  MediaStream? _localStream;

  bool _isLoading = true;
  bool _isCameraOn = false;

  ///
  @override
  void initState() {
    super.initState();

    _localRenderer = RTCVideoRenderer();

    initRenderers().then((_) => _startLocalStream());
  }

  ///
  @override
  void dispose() {
    if (_localRenderer != null) {
      _localRenderer!.dispose();
    }

    _localStream?.dispose();

    super.dispose();
  }

  ///
  Future<void> initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer!.initialize();
    }
  }

  ///
  Future<void> _startLocalStream() async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'}
    };

    setState(() => _isLoading = true);

    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      if (_localRenderer != null) {
        _localRenderer!.srcObject = _localStream;
      }

      setState(() {
        _isCameraOn = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error accessing media devices: $e');

      setState(() {
        _isLoading = false;
        _isCameraOn = false;
      });
    }
  }

  ///
  void _stopLocalStream() {
    _localStream?.getTracks().forEach((track) => track.stop());

    _localRenderer?.srcObject = null;

    _localStream = null;

    setState(() => _isCameraOn = false);
  }

  ///
  void _toggleCamera() =>
      (_isCameraOn) ? _stopLocalStream() : _startLocalStream();

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter WebRTC Sample")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isCameraOn
                ? RTCVideoView(_localRenderer!)
                : Container(
                    color: Colors.black,
                    // width: double.infinity,
                    // height: double.infinity,
                    width: 645,
                    height: 645,
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        child: Icon(_isCameraOn ? Icons.videocam_off : Icons.videocam),
      ),
    );
  }
}
