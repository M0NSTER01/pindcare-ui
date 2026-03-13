import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/socket_service.dart';
import '../../shared/providers/auth_provider.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String? consultationId;
  final String callType; // 'video' or 'audio'
  const VideoCallScreen({super.key, this.consultationId, this.callType = 'video'});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallState();
}

class _VideoCallState extends ConsumerState<VideoCallScreen> {
  // WebRTC
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _callConnected = false;
  bool _isAudioOnly = false;
  int _seconds = 0;

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _isAudioOnly = widget.callType == 'audio';
    _initWebRTC();
    _startTimer();
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Get local media
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': _isAudioOnly ? false : {'facingMode': 'user'},
    });
    _localRenderer.srcObject = _localStream;

    // Create peer connection
    _pc = await createPeerConnection(_iceServers);

    _localStream!.getTracks().forEach((t) => _pc!.addTrack(t, _localStream!));

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _callConnected = true;
        });
      }
    };

    _pc!.onIceCandidate = (candidate) {
      final consId = widget.consultationId ?? '';
      final userId = ref.read(authProvider)?.id ?? '';
      SocketService().sendIceCandidate(consId, userId, candidate.toMap());
    };

    _pc!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed &&
          !_isAudioOnly) {
        _fallbackToAudio();
      }
    };

    // Socket signaling listeners
    final consId = widget.consultationId ?? '';
    final userId = ref.read(authProvider)?.id ?? '';

    SocketService().on('webrtc_offer', (data) async {
      final map = Map<String, dynamic>.from(data as Map);
      await _pc!.setRemoteDescription(RTCSessionDescription(
        map['offer']['sdp'], map['offer']['type']));
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      SocketService().sendAnswer(consId, userId, answer.toMap());
    });

    SocketService().on('webrtc_answer', (data) async {
      final map = Map<String, dynamic>.from(data as Map);
      await _pc!.setRemoteDescription(RTCSessionDescription(
        map['answer']['sdp'], map['answer']['type']));
    });

    SocketService().on('webrtc_ice_candidate', (data) async {
      final map = Map<String, dynamic>.from(data as Map);
      final c = map['candidate'];
      await _pc!.addCandidate(RTCIceCandidate(
        c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    });

    SocketService().on('toggle_call_type', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      if (mounted) setState(() => _isAudioOnly = map['new_type'] == 'audio');
    });

    SocketService().on('end_call', (_) {
      if (mounted) Navigator.pop(context);
    });

    // If this side is the caller — create and send offer
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    SocketService().sendOffer(consId, userId, offer.toMap(), widget.callType);

    if (mounted) setState(() {});
  }

  void _fallbackToAudio() {
    if (!mounted) return;
    setState(() => _isAudioOnly = true);
    _localStream?.getVideoTracks().forEach((t) => t.enabled = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switched to audio only due to poor connection')),
    );
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds++);
      return true;
    });
  }

  String get _timerText {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleCallType() async {
    final consId = widget.consultationId ?? '';
    final userId = ref.read(authProvider)?.id ?? '';
    final newType = _isAudioOnly ? 'video' : 'audio';

    setState(() => _isAudioOnly = !_isAudioOnly);
    _localStream?.getVideoTracks().forEach((t) => t.enabled = !_isAudioOnly);

    SocketService().toggleCallType(consId, userId, newType);

    // Renegotiate
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    SocketService().sendOffer(consId, userId, offer.toMap(), newType);
  }

  Future<void> _endCall() async {
    final consId = widget.consultationId ?? '';
    final userId = ref.read(authProvider)?.id ?? '';
    SocketService().endCall(consId, userId);
    await _dispose();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _dispose() async {
    SocketService().off('webrtc_offer');
    SocketService().off('webrtc_answer');
    SocketService().off('webrtc_ice_candidate');
    SocketService().off('toggle_call_type');
    SocketService().off('end_call');
    _localStream?.getTracks().forEach((t) => t.stop());
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _pc?.close();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Remote video (full screen)
        !_isAudioOnly && _callConnected
            ? RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
            : Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 100, height: 100, decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, size: 52, color: Colors.white54)),
                  const SizedBox(height: 16),
                  Text(_callConnected ? 'Audio Call' : 'Connecting...',
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
                ]))),

        // Local video PIP (hidden in audio-only)
        if (!_isAudioOnly)
          Positioned(top: 60, right: 16, child: Container(
            width: 100, height: 140,
            decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)),
            child: ClipRRect(borderRadius: BorderRadius.circular(14),
              child: _isVideoOff
                  ? Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 32))
                  : RTCVideoView(_localRenderer, mirror: true)))),

        // Top bar
        Positioned(top: 0, left: 0, right: 0, child: Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 12),
          decoration: BoxDecoration(gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_timerText, style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ])),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.signal_cellular_alt_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(_callConnected ? 'Connected' : 'Connecting',
                  style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
              ])),
          ]))),

        // Bottom controls
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _controlBtn(Icons.mic_off_rounded, Icons.mic_rounded, _isMuted, 'Mute', () {
              setState(() => _isMuted = !_isMuted);
              _localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
            }),
            _controlBtn(
              _isAudioOnly ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              _isAudioOnly ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              _isAudioOnly, _isAudioOnly ? 'Enable Video' : 'Video Only',
              _toggleCallType),
            // End call
            GestureDetector(onTap: () { HapticFeedback.heavyImpact(); _endCall(); },
              child: Container(width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 16)]),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30))),
            _controlBtn(Icons.volume_up_rounded, Icons.volume_off_rounded, _isSpeakerOn, 'Speaker',
              () => setState(() => _isSpeakerOn = !_isSpeakerOn)),
            _controlBtn(Icons.flip_camera_android_rounded, Icons.flip_camera_android_rounded, false, 'Flip',
              () => _localStream?.getVideoTracks().forEach((t) => Helper.switchCamera(t))),
          ]))),
      ]),
    );
  }

  Widget _controlBtn(IconData activeIcon, IconData inactiveIcon, bool isActive, String label, VoidCallback onTap) {
    return GestureDetector(onTap: () { HapticFeedback.mediumImpact(); onTap(); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle),
          child: Icon(isActive ? activeIcon : inactiveIcon, color: Colors.white, size: 24)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 10)),
      ]));
  }
}
