import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/chat/data/chat_service.dart';

class ChatCubit extends Cubit<void> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(null);

  void sendMessage(
    String chatId,
    String text,
    String senderId,
    String receiverId,
  ) {
    _chatService.sendMessage(chatId, text, senderId, receiverId: receiverId);
  }

  void markMessagesAsRead(String chatId, String currentUserId) {
    _chatService.markMessagesAsRead(chatId, currentUserId);
  }

  void toggleReaction(
    String chatId,
    String messageId,
    String userId,
    String emoji,
  ) {
    _chatService.toggleReaction(chatId, messageId, userId, emoji);
  }
}
