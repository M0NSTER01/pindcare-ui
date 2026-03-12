import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class VideoCallScreen extends StatefulWidget {
  final String? appointmentId;
  const VideoCallScreen({super.key, this.appointmentId});
  @override
  State<VideoCallScreen> createState() => _State();
}

class _State extends State<VideoCallScreen> {
  bool _isMuted = false, _isCameraOff = false, _isSpeakerOn = true, _showChat = false;
  int _seconds = 0;
  bool _callConnected = true;
  final _chatCtrl = TextEditingController();
  final List<Map<String, String>> _chatMessages = [
    {'sender': 'Dr. Amandeep', 'message': 'Can you show the affected area?', 'time': '2:15'},
    {'sender': 'You', 'message': 'Yes, showing now', 'time': '2:16'},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  @override
  void dispose() { _chatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Remote video (full screen placeholder)
        Container(decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.grey[800]!], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Text('AK', style: AppTextStyles.heading2.copyWith(color: Colors.white)))),
            const SizedBox(height: 16),
            Text('Dr. Amandeep Kaur', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text('General Physician', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
          ]))),
        // Local video PIP
        Positioned(top: 60, right: 16, child: Container(
          width: 100, height: 140,
          decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)),
          child: ClipRRect(borderRadius: BorderRadius.circular(14),
            child: _isCameraOff
              ? Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 32))
              : Container(color: AppColors.primary.withValues(alpha: 0.3),
                child: Center(child: Text('You', style: AppTextStyles.caption.copyWith(color: Colors.white70))))))),
        // Top overlay
        Positioned(top: 0, left: 0, right: 0, child: Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 12),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
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
                Text('Good', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
              ])),
          ]))),
        // Bottom controls
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _controlBtn(Icons.mic_off_rounded, Icons.mic_rounded, _isMuted, 'Mute',
              () => setState(() => _isMuted = !_isMuted)),
            _controlBtn(Icons.videocam_off_rounded, Icons.videocam_rounded, _isCameraOff, 'Camera',
              () => setState(() => _isCameraOff = !_isCameraOff)),
            // End call
            GestureDetector(onTap: () { HapticFeedback.heavyImpact(); _showEndCallDialog(); },
              child: Container(width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 16)]),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30))),
            _controlBtn(Icons.volume_up_rounded, Icons.volume_off_rounded, _isSpeakerOn, 'Speaker',
              () => setState(() => _isSpeakerOn = !_isSpeakerOn)),
            _controlBtn(Icons.chat_rounded, Icons.chat_outlined, _showChat, 'Chat',
              () => setState(() => _showChat = !_showChat)),
          ]))),
        // Chat overlay
        if (_showChat) Positioned(bottom: 100, left: 16, right: 16, child: Container(
          height: 300, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text('Chat', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
                const Spacer(),
                GestureDetector(onTap: () => setState(() => _showChat = false),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20)),
              ])),
            const Divider(color: Colors.white12, height: 1),
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.all(12), itemCount: _chatMessages.length,
              itemBuilder: (_, i) {
                final msg = _chatMessages[i]; final isMe = msg['sender'] == 'You';
                return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: isMe ? AppColors.primary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                      Text(msg['message']!, style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
                      Text(msg['time']!, style: AppTextStyles.caption.copyWith(color: Colors.white38, fontSize: 10)),
                    ])));
              })),
            Container(padding: const EdgeInsets.all(8), child: Row(children: [
              Expanded(child: TextField(controller: _chatCtrl,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                decoration: InputDecoration(hintText: 'Type a message...', hintStyle: const TextStyle(color: Colors.white30),
                  filled: true, fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
              const SizedBox(width: 8),
              GestureDetector(onTap: () {
                if (_chatCtrl.text.trim().isEmpty) return;
                setState(() { _chatMessages.add({'sender': 'You', 'message': _chatCtrl.text.trim(), 'time': _timerText}); _chatCtrl.clear(); });
              }, child: Container(width: 40, height: 40, decoration: BoxDecoration(
                color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
            ])),
          ]))).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1),
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

  void _showEndCallDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('End Call?'), content: const Text('Are you sure you want to end this consultation?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue')),
        TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
          child: const Text('End Call', style: TextStyle(color: Colors.red))),
      ]));
  }
}
