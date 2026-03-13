import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/socket_service.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/consultation_provider.dart';

/// Audio / Video call screen.
/// Uses Socket.IO for signaling (call offer/answer/end).
/// Displays a "connecting" UI while waiting for the remote peer.
///
/// Pass route extras: {'consultationId': String, 'callType': 'video'|'audio', 'isOutgoing': bool}
class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});
  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen>
    with TickerProviderStateMixin {
  bool _micEnabled  = true;
  bool _speakerOn   = true;
  bool _isVideo     = true;
  bool _connected   = false;
  bool _callEnded   = false;
  String _status    = 'Calling...';
  Duration _elapsed = Duration.zero;
  late final AnimationController _pulseCtrl;
  final SocketService _socket = SocketService();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    // Listen for call accepted / ended events
    _socket.onCallAccepted(() {
      if (mounted) setState(() { _connected = true; _status = 'Connected'; });
      _startTimer();
    });

    _socket.onCallEnded(() {
      if (mounted) setState(() { _callEnded = true; _status = 'Call Ended'; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.pop();
      });
    });

    // Emit call offer signal after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consultId = ref.read(consultationProvider)?.id.toString() ?? '';
      final userId    = ref.read(authProvider)?.id ?? '';
      _socket.emitCallOffer(consultId, userId, _isVideo ? 'video' : 'audio');
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  int _seconds = 0;
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _callEnded) return false;
      setState(() { _seconds++; _elapsed = Duration(seconds: _seconds); });
      return true;
    });
  }

  String _formatTime(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  void _endCall() {
    HapticFeedback.heavyImpact();
    final consultId = ref.read(consultationProvider)?.id.toString() ?? '';
    final userId    = ref.read(authProvider)?.id ?? '';
    _socket.emitEndCall(consultId, userId);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final consultation = ref.watch(consultationProvider);
    final myUser       = ref.watch(authProvider);
    final peerName     = myUser?.role == 'doctor'
        ? (consultation?.patientName ?? 'Patient')
        : (consultation?.doctorName  ?? 'Doctor');

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Stack(children: [
          // Background gradient
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1A3A5C)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          )),

          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _connected ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _connected ? Colors.green.withValues(alpha: 0.5) : Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(
                      color: _connected ? Colors.green : Colors.orange, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(_connected ? _formatTime(_elapsed) : _status,
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),

            // ── Center avatar + name ──────────────────────────────────────────
            Column(children: [
              // Pulse animation
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 130 + (_connected ? 0 : _pulseCtrl.value * 20),
                  height: 130 + (_connected ? 0 : _pulseCtrl.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05 * (1 - _pulseCtrl.value)),
                  ),
                  child: Center(child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 30)],
                    ),
                    child: Center(child: Text(
                      peerName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    )),
                  )),
                ),
              ),

              const SizedBox(height: 24),

              Text(peerName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_connected ? (_isVideo ? '🎥 Video Call' : '🎙️ Audio Call') : 'Connecting via PindCare...',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16)),
            ]),

            // ── Call controls ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(children: [
                // Secondary controls row
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _controlBtn(icon: _micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: _micEnabled ? 'Mute' : 'Unmute',
                    color: _micEnabled ? Colors.white24 : Colors.red.withValues(alpha: 0.4),
                    onTap: () { HapticFeedback.selectionClick(); setState(() => _micEnabled = !_micEnabled); }),
                  const SizedBox(width: 20),
                  _controlBtn(icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    label: _speakerOn ? 'Speaker' : 'Earpiece',
                    color: Colors.white24,
                    onTap: () { HapticFeedback.selectionClick(); setState(() => _speakerOn = !_speakerOn); }),
                  const SizedBox(width: 20),
                  _controlBtn(icon: _isVideo ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    label: _isVideo ? 'Camera' : 'No Camera',
                    color: Colors.white24,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isVideo = !_isVideo);
                      final consultId = ref.read(consultationProvider)?.id.toString() ?? '';
                      final userId    = ref.read(authProvider)?.id ?? '';
                      _socket.emitToggleCallType(consultId, userId, _isVideo ? 'video' : 'audio');
                    }),
                ]),

                const SizedBox(height: 32),

                // End call button
                GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 20)],
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
                  ).animate().scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.elasticOut),
                ),
                const SizedBox(height: 8),
                Text('End Call', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _controlBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
      ]),
    );
  }
}
