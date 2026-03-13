import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/consultation_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/socket_service.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/consultation_provider.dart';
import '../../shared/widgets/triage_card_widget.dart';
import '../video_call/video_call_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Chat List Screen (unchanged flow, kept simple)
// ─────────────────────────────────────────────────────────────────────────────
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatListScreen> {
  String _filter = 'All';
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final raw = await ApiService().getMyConsultations();
      setState(() {
        _conversations = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadConversations),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('No consultations yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ]),
                )
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (_, i) => _convTile(_conversations[i], i),
                ),
    );
  }

  Widget _convTile(Map<String, dynamic> conv, int index) {
    final doctorName = conv['doctor_name'] ?? conv['doctorName'] ?? 'Doctor';
    final status = conv['status'] ?? 'pending';
    final initials = doctorName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();
    final consultation = ConsultationModel.fromMap(conv);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatDetailScreen(consultation: consultation),
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: Center(child: Text(initials, style: AppTextStyles.bodyBold.copyWith(color: Colors.white)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctorName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text(status, style: AppTextStyles.caption.copyWith(
              color: status == 'active' ? AppColors.success : AppColors.textHint)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80), duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Detail Screen
// ─────────────────────────────────────────────────────────────────────────────
class ChatDetailScreen extends ConsumerStatefulWidget {
  final ConsultationModel consultation;
  const ChatDetailScreen({super.key, required this.consultation});
  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailState();
}

class _ChatDetailState extends ConsumerState<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider)?.id ?? '';
      ref.read(consultationProvider.notifier)
          .loadConsultation(widget.consultation.id, userId);
    });
  }

  @override
  void dispose() {
    ref.read(consultationProvider.notifier).cleanup();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    final user = ref.read(authProvider);
    if (user == null) return;
    SocketService().sendMessage(
      widget.consultation.id,
      user.id,
      _msgCtrl.text.trim(),
    );
    // Optimistic local append
    ref.read(consultationProvider.notifier).appendMessage(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: widget.consultation.id,
      senderId: user.id,
      receiverId: '',
      senderName: user.name,
      receiverName: '',
      content: _msgCtrl.text.trim(),
    ));
    _msgCtrl.clear();
    _scrollToBottom();
  }

  void _onTextChanged(String text) {
    final user = ref.read(authProvider);
    if (user != null) {
      SocketService().sendTyping(widget.consultation.id, user.id);
    }
  }

  Future<void> _sendImage() async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt_rounded), title: const Text('Camera'),
          onTap: () => Navigator.pop(context, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_rounded), title: const Text('Gallery'),
          onTap: () => Navigator.pop(context, ImageSource.gallery)),
      ]),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final result = await ApiService().uploadChatImage(
          widget.consultation.id, image.path);
      if (!mounted) return;
      final imageUrl = result['image_url'] ?? result['imageUrl'] ?? '';
      ref.read(consultationProvider.notifier).appendMessage(ChatMessageModel(
        id: result['message_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: widget.consultation.id,
        senderId: ref.read(authProvider)?.id ?? '',
        receiverId: '',
        senderName: ref.read(authProvider)?.name ?? '',
        receiverName: '',
        content: '',
        type: 'image',
        imageUrl: imageUrl,
      ));
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consultationProvider);
    final currentUserId = ref.watch(authProvider)?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: Center(child: Text(
              widget.consultation.doctorInitials.isNotEmpty
                  ? widget.consultation.doctorInitials
                  : widget.consultation.doctorName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase(),
              style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.consultation.doctorName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
            Text(widget.consultation.isOnline ? 'Online' : 'Offline',
              style: AppTextStyles.caption.copyWith(fontSize: 11,
                color: widget.consultation.isOnline ? AppColors.success : AppColors.textHint)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                consultationId: widget.consultation.id,
                callType: 'video',
              ),
            ));
          }),
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                consultationId: widget.consultation.id,
                callType: 'audio',
              ),
            ));
          }),
        ],
      ),
      body: Column(children: [
        // AI Triage card
        if (widget.consultation.scanId != null)
          TriageCardWidget(scanId: widget.consultation.scanId!),

        // Messages
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (_, i) => _bubble(state.messages[i], currentUserId),
                ),
        ),

        // Typing indicator
        if (state.isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Doctor is typing...', style: AppTextStyles.caption.copyWith(
                color: AppColors.primary, fontStyle: FontStyle.italic)),
            ),
          ),

        // Upload progress
        if (_uploading)
          LinearProgressIndicator(color: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15)),

        _inputBar(),
      ]),
    );
  }

  Widget _bubble(ChatMessageModel msg, String currentUserId) {
    final isMe = msg.senderId == currentUserId;
    final isPrescription = msg.type == 'prescription';
    final isImage = msg.type == 'image';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.symmetric(horizontal: isImage ? 4 : 14, vertical: isImage ? 4 : 10),
        decoration: BoxDecoration(
          color: isPrescription ? AppColors.primary.withValues(alpha: 0.1)
              : isMe ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4), bottomRight: Radius.circular(isMe ? 4 : 18)),
          border: isPrescription ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          if (isPrescription) Padding(padding: const EdgeInsets.only(bottom: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.medication_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('Prescription', style: AppTextStyles.caption.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ])),
          if (isImage && msg.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: '${ApiConfig.baseHost}${msg.imageUrl}',
                width: 200, height: 150, fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 200, height: 150,
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded),
              ),
            )
          else if (!isImage)
            Text(msg.content, style: AppTextStyles.bodySmall.copyWith(
              color: isPrescription ? AppColors.textPrimary : isMe ? Colors.white : AppColors.textPrimary,
              fontSize: 14)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text('${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption.copyWith(
                color: isMe ? Colors.white.withValues(alpha: 0.6) : AppColors.textHint, fontSize: 10)),
            if (isMe) ...[const SizedBox(width: 4),
              Icon(Icons.done_all_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6))],
          ]),
        ]),
      ),
    );
  }

  Widget _inputBar() => Container(
    padding: EdgeInsets.fromLTRB(8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(color: AppColors.cardBackground,
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, -2))]),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.image_rounded, color: AppColors.primary), onPressed: _sendImage),
      Expanded(child: TextField(controller: _msgCtrl,
        style: AppTextStyles.bodyMedium,
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          hintText: 'Type a message...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          filled: true, fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
      const SizedBox(width: 4),
      GestureDetector(onTap: _sendMessage,
        child: Container(width: 44, height: 44,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
    ]),
  );
}
