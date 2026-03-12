class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String content;
  final String type; // text, audio, image, video, ai_scan, prescription, file
  final String status; // sending, sent, delivered, read
  final String? filePath;
  final int? durationSeconds; // for audio/video
  final String? thumbnailPath;
  final Map<String, dynamic>? metadata; // extra data for special types
  final String? memberId;
  final String syncStatus;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.content,
    this.type = 'text',
    this.status = 'sent',
    this.filePath,
    this.durationSeconds,
    this.thumbnailPath,
    this.metadata,
    this.memberId,
    this.syncStatus = 'synced',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isText => type == 'text';
  bool get isAudio => type == 'audio';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAiScan => type == 'ai_scan';
  bool get isPrescription => type == 'prescription';

  Map<String, dynamic> toMap() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'senderName': senderName,
        'receiverName': receiverName,
        'content': content,
        'type': type,
        'status': status,
        'filePath': filePath,
        'durationSeconds': durationSeconds,
        'thumbnailPath': thumbnailPath,
        'metadata': metadata,
        'memberId': memberId,
        'syncStatus': syncStatus,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) => ChatMessageModel(
        id: map['id'] ?? '',
        conversationId: map['conversationId'] ?? '',
        senderId: map['senderId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        senderName: map['senderName'] ?? '',
        receiverName: map['receiverName'] ?? '',
        content: map['content'] ?? '',
        type: map['type'] ?? 'text',
        status: map['status'] ?? 'sent',
        filePath: map['filePath'],
        durationSeconds: map['durationSeconds'],
        thumbnailPath: map['thumbnailPath'],
        metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
        memberId: map['memberId'],
        syncStatus: map['syncStatus'] ?? 'synced',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );
}

class ConversationModel {
  final String id;
  final String peerId;
  final String peerName;
  final String peerRole; // doctor, patient, asha
  final String? peerPhoto;
  final String? lastMessage;
  final String? lastMessageType;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ConversationModel({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerRole,
    this.peerPhoto,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  String get peerInitials =>
      peerName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

  Map<String, dynamic> toMap() => {
        'id': id,
        'peerId': peerId,
        'peerName': peerName,
        'peerRole': peerRole,
        'peerPhoto': peerPhoto,
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'unreadCount': unreadCount,
        'isOnline': isOnline,
      };

  factory ConversationModel.fromMap(Map<String, dynamic> map) => ConversationModel(
        id: map['id'] ?? '',
        peerId: map['peerId'] ?? '',
        peerName: map['peerName'] ?? '',
        peerRole: map['peerRole'] ?? '',
        peerPhoto: map['peerPhoto'],
        lastMessage: map['lastMessage'],
        lastMessageType: map['lastMessageType'],
        lastMessageTime: DateTime.tryParse(map['lastMessageTime'] ?? ''),
        unreadCount: map['unreadCount'] ?? 0,
        isOnline: map['isOnline'] ?? false,
      );
}
