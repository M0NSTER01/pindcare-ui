import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/consultation_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/socket_service.dart';

class ConsultationState {
  final ConsultationModel? active;
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final bool isLoading;

  const ConsultationState({
    this.active,
    this.messages = const [],
    this.isTyping = false,
    this.isLoading = false,
  });

  ConsultationState copyWith({
    ConsultationModel? active,
    List<ChatMessageModel>? messages,
    bool? isTyping,
    bool? isLoading,
  }) =>
      ConsultationState(
        active: active ?? this.active,
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ConsultationNotifier extends StateNotifier<ConsultationState> {
  ConsultationNotifier() : super(const ConsultationState());

  /// Load history and join socket room for a consultation.
  Future<void> loadConsultation(
      String consultationId, String currentUserId) async {
    state = state.copyWith(isLoading: true);

    // Join socket room
    SocketService().joinConsultation(consultationId, currentUserId);

    // Listen for real-time messages
    SocketService().on('new_message', (data) {
      if (!mounted) return;
      final msg = ChatMessageModel.fromApiMap(
          Map<String, dynamic>.from(data as Map));
      state = state.copyWith(messages: [...state.messages, msg]);
    });

    // Listen for typing events
    SocketService().on('typing', (data) {
      if (!mounted) return;
      state = state.copyWith(isTyping: true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) state = state.copyWith(isTyping: false);
      });
    });

    // Load chat history
    try {
      final history = await ApiService().getChatMessages(consultationId);
      final messages = history
          .map((m) =>
              ChatMessageModel.fromApiMap(Map<String, dynamic>.from(m as Map)))
          .toList();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setActive(ConsultationModel consultation) {
    state = state.copyWith(active: consultation);
  }

  void appendMessage(ChatMessageModel msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void cleanup() {
    if (state.active != null) {
      SocketService().off('new_message');
      SocketService().off('typing');
    }
  }
}

final consultationProvider =
    StateNotifierProvider<ConsultationNotifier, ConsultationState>(
  (_) => ConsultationNotifier(),
);
