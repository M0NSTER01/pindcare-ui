import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api_config.dart';

/// Singleton Socket.IO client for real-time chat and WebRTC signaling.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  io.Socket get socket => _socket!;

  bool get isConnected => _socket?.connected ?? false;

  // ── Connection ────────────────────────────────────────────────────────────

  void connect(String userId) {
    _socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
    _socket!.emit('join', {'user_id': userId});
    _socket!.on('connect', (_) {
      // Re-emit join on reconnect
      _socket!.emit('join', {'user_id': userId});
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // ── Consultation Room ─────────────────────────────────────────────────────

  void joinConsultation(String consultationId, String userId) {
    _socket?.emit('join_consultation', {
      'consultation_id': consultationId,
      'user_id': userId,
    });
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  void sendMessage(String consultationId, String senderId, String text) {
    _socket?.emit('send_message', {
      'consultation_id': consultationId,
      'sender_id': senderId,
      'message_text': text,
    });
  }

  void sendTyping(String consultationId, String userId) {
    _socket?.emit('typing', {
      'consultation_id': consultationId,
      'user_id': userId,
    });
  }

  // ── WebRTC Signaling ──────────────────────────────────────────────────────

  void sendOffer(String consultationId, String fromUserId, dynamic offer,
      String callType) {
    _socket?.emit('webrtc_offer', {
      'consultation_id': consultationId,
      'from_user_id': fromUserId,
      'offer': offer,
      'call_type': callType, // 'video' | 'audio'
    });
  }

  void sendAnswer(
      String consultationId, String fromUserId, dynamic answer) {
    _socket?.emit('webrtc_answer', {
      'consultation_id': consultationId,
      'from_user_id': fromUserId,
      'answer': answer,
    });
  }

  void sendIceCandidate(
      String consultationId, String fromUserId, dynamic candidate) {
    _socket?.emit('webrtc_ice_candidate', {
      'consultation_id': consultationId,
      'from_user_id': fromUserId,
      'candidate': candidate,
    });
  }

  void toggleCallType(
      String consultationId, String userId, String newType) {
    _socket?.emit('toggle_call_type', {
      'consultation_id': consultationId,
      'user_id': userId,
      'new_type': newType,
    });
  }

  void endCall(String consultationId, String userId) {
    _socket?.emit('end_call', {
      'consultation_id': consultationId,
      'user_id': userId,
    });
  }

  // ── Listener helpers ──────────────────────────────────────────────────────

  void on(String event, Function(dynamic) handler) =>
      _socket?.on(event, handler);

  void off(String event) => _socket?.off(event);
}
