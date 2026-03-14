import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/chat_message.dart';
import '../../data/services/chat_service.dart';

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdvancedChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(messages: []);
  }

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final chatService = ref.read(aiChatServiceProvider);
      final responseText = await chatService.getResponse(text);
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        text: "Sorry, I'm having trouble connecting right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: []);
  }
}

final advancedChatProvider = NotifierProvider<AdvancedChatNotifier, ChatState>(() {
  return AdvancedChatNotifier();
});
