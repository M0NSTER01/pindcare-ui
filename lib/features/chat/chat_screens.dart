import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/chat_message_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _State();
}

class _State extends State<ChatListScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  final List<ConversationModel> _conversations = [
    ConversationModel(id: 'C1', peerId: 'D1', peerName: 'Dr. Amandeep Kaur', peerRole: 'doctor',
      lastMessage: 'Take the prescribed medicines regularly', lastMessageType: 'text',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)), unreadCount: 2, isOnline: true),
    ConversationModel(id: 'C2', peerId: 'D2', peerName: 'Dr. Gurjeet Singh', peerRole: 'doctor',
      lastMessage: '🎤 Audio message (0:32)', lastMessageType: 'audio',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)), unreadCount: 0, isOnline: false),
    ConversationModel(id: 'C3', peerId: 'D3', peerName: 'Dr. Manpreet Kaur', peerRole: 'doctor',
      lastMessage: 'Your lab results look normal', lastMessageType: 'text',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)), unreadCount: 0, isOnline: true),
    ConversationModel(id: 'C4', peerId: 'P1', peerName: 'Rajinder Singh', peerRole: 'patient',
      lastMessage: 'Thank you for the prescription', lastMessageType: 'text',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)), unreadCount: 1, isOnline: false),
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
      ]),
      body: Column(children: [
        // Filters
        SizedBox(height: 40, child: ListView(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          children: ['All', 'Doctors', 'Patients', 'Unread'].map((f) {
            final sel = f == _filter;
            return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
              label: Text(f), selected: sel,
              selectedColor: AppColors.primary.withValues(alpha: 0.15), checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.labelSmall.copyWith(color: sel ? AppColors.primary : AppColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: sel ? AppColors.primary : AppColors.divider)),
              onSelected: (_) => setState(() => _filter = f)));
          }).toList())),
        const SizedBox(height: 8),
        // Online now
        SizedBox(height: 80, child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _conversations.where((c) => c.isOnline).length,
          itemBuilder: (_, i) {
            final c = _conversations.where((c) => c.isOnline).toList()[i];
            return Padding(padding: const EdgeInsets.only(right: 14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                    child: Center(child: Text(c.peerInitials, style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 14)))),
                  Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14,
                    decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)))),
                ]),
                const SizedBox(height: 4),
                Text(c.peerName.split(' ').first, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ]));
          })),
        const Divider(height: 1),
        // Conversation list
        Expanded(child: ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (_, i) => _convTile(_conversations[i], i))),
      ]),
    );
  }

  Widget _convTile(ConversationModel conv, int index) {
    final timeAgo = _formatTime(conv.lastMessageTime);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conv))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Stack(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(
              gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Center(child: Text(conv.peerInitials, style: AppTextStyles.bodyBold.copyWith(color: Colors.white)))),
            if (conv.isOnline) Positioned(bottom: 2, right: 2, child: Container(width: 12, height: 12,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2)))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(conv.peerName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15))),
              Text(timeAgo, style: AppTextStyles.caption.copyWith(
                color: conv.unreadCount > 0 ? AppColors.primary : AppColors.textHint, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              if (conv.lastMessageType == 'audio') const Icon(Icons.mic_rounded, size: 14, color: AppColors.textHint),
              if (conv.lastMessageType == 'image') const Icon(Icons.image_rounded, size: 14, color: AppColors.textHint),
              if (conv.lastMessageType != 'text') const SizedBox(width: 4),
              Expanded(child: Text(conv.lastMessage ?? '', style: AppTextStyles.bodySmall.copyWith(fontSize: 13,
                color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (conv.unreadCount > 0) Container(width: 22, height: 22,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text('${conv.unreadCount}', style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))),
            ]),
          ])),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80), duration: 300.ms);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatDetailScreen({super.key, required this.conversation});
  @override
  State<ChatDetailScreen> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ChatMessageModel(id: '1', conversationId: 'C1', senderId: 'D1', receiverId: 'P1',
        senderName: 'Dr. Amandeep', receiverName: 'You', content: 'Hello! How are you feeling today?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      ChatMessageModel(id: '2', conversationId: 'C1', senderId: 'P1', receiverId: 'D1',
        senderName: 'You', receiverName: 'Dr. Amandeep', content: 'I am feeling much better after the medicines.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50))),
      ChatMessageModel(id: '3', conversationId: 'C1', senderId: 'D1', receiverId: 'P1',
        senderName: 'Dr. Amandeep', receiverName: 'You', content: 'Good to hear! Continue the medication for 5 more days.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45))),
      ChatMessageModel(id: '4', conversationId: 'C1', senderId: 'D1', receiverId: 'P1',
        senderName: 'Dr. Amandeep', receiverName: 'You', content: 'Take Paracetamol 500mg twice daily after meals.\nMetformin 500mg once daily.\nDrink plenty of water.',
        type: 'prescription', timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40))),
      ChatMessageModel(id: '5', conversationId: 'C1', senderId: 'P1', receiverId: 'D1',
        senderName: 'You', receiverName: 'Dr. Amandeep', content: 'Thank you doctor!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    ]);
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessageModel(id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: 'C1', senderId: 'P1', receiverId: 'D1', senderName: 'You',
        receiverName: widget.conversation.peerName, content: _msgCtrl.text.trim()));
      _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: Center(child: Text(widget.conversation.peerInitials,
              style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.conversation.peerName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
            Text(widget.conversation.isOnline ? 'Online' : 'Offline',
              style: AppTextStyles.caption.copyWith(fontSize: 11, color: widget.conversation.isOnline ? AppColors.success : AppColors.textHint)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scrollCtrl, padding: const EdgeInsets.all(16), itemCount: _messages.length,
          itemBuilder: (_, i) => _bubble(_messages[i]))),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(ChatMessageModel msg) {
    final isMe = msg.senderName == 'You';
    final isPrescription = msg.type == 'prescription';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              Text('Prescription', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ])),
          Text(msg.content, style: AppTextStyles.bodySmall.copyWith(
            color: isPrescription ? AppColors.textPrimary : isMe ? Colors.white : AppColors.textPrimary, fontSize: 14)),
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
      IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary), onPressed: () {}),
      Expanded(child: TextField(controller: _msgCtrl, style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          filled: true, fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
      const SizedBox(width: 4),
      GestureDetector(onTap: _sendMessage,
        child: Container(width: 44, height: 44, decoration: BoxDecoration(
          gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
    ]),
  );
}
