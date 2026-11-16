import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config.dart';

class CallScreen extends StatefulWidget {
  final String gender;
  final String channel;
  final String token;
  const CallScreen({
    super.key,
    required this.gender,
    required this.channel,
    this.token = '',
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _muted = false;
  bool _cameraOff = false;
  String _status = 'Connecting...';
  String? _fatalError;
  bool _permissionIssue = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cleanup();
    if (mounted) setState(() => _fatalError = null);
    if (agoraAppId.isEmpty || agoraAppId.startsWith('PASTE')) {
      if (!mounted) return;
      setState(() => _fatalError =
          'Agora App ID set nahi hai. lib/config.dart me App ID daalo.');
      return;
    }

    _permissionIssue = false;
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      if (!mounted) return;
      setState(() {
        _permissionIssue = true;
        _fatalError =
            'Camera aur Microphone ki permission do (Settings > Apps > Permissions).';
      });
      return;
    }

    try {
      final engine = createAgoraRtcEngine();
      _engine = engine;

      await engine.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (!mounted) return;
          setState(() => _status = 'Room me ho. Doosre user ka wait...');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (!mounted) return;
          setState(() {
            _remoteUid = remoteUid;
            _status = 'Connected';
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (!mounted) return;
          setState(() {
            _remoteUid = null;
            _status = 'Doosre user ne call chhod di. Wait...';
          });
        },
        onError: (ErrorCodeType err, String msg) {
          if (!mounted) return;
          String hint = '';
          if (err == ErrorCodeType.errInvalidToken ||
              err == ErrorCodeType.errTokenExpired) {
            hint = '\n\nToken galat ya expire hai. Call kaat kar back jao aur '
                'Agora console se naya Temp Token (isi Channel name ke liye) '
                'home screen par paste karo.';
          }
          setState(() => _status = 'Error: $err $msg$hint');
        },
        onTokenPrivilegeWillExpire:
            (RtcConnection connection, String token) {
          if (!mounted) return;
          setState(() => _status =
              'Token jaldi expire hoga. Naya token paste karke dobara join karo.');
        },
      ));

      await engine.enableVideo();
      await engine.startPreview();

      await engine.joinChannel(
        token: widget.token,
        channelId: widget.channel,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _fatalError = 'Call start nahi hui: $e');
    }
  }

  Future<void> _cleanup() async {
    final engine = _engine;
    _engine = null;
    if (engine == null) return;
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (_) {}
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _endCall() async {
    await _cleanup();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _cameraOff = !_cameraOff);
    await _engine?.muteLocalVideoStream(_cameraOff);
  }

  Widget _remoteView() {
    final engine = _engine;
    if (engine != null && _remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channel),
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localView() {
    final engine = _engine;
    if (engine == null || _cameraOff) {
      return Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.videocam_off, color: Colors.white),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {Color color = Colors.white24}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fatalError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_fatalError!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _init,
                  child: const Text('Dobara try karo'),
                ),
                if (_permissionIssue) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: openAppSettings,
                    child: const Text('Settings kholo (Permission allow karo)'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _remoteView()),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tum: ${widget.gender}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              width: 110,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _localView(),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn(_muted ? Icons.mic_off : Icons.mic, _toggleMute),
                  _btn(_cameraOff ? Icons.videocam_off : Icons.videocam,
                      _toggleCamera),
                  _btn(Icons.cameraswitch, () => _engine?.switchCamera()),
                  _btn(Icons.call_end, _endCall, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
