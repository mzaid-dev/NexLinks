import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/data/chat_service.dart';

class ChatCubit extends Cubit<void> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(null);

  void sendMessage(String chatId, String text, String senderId) {
    _chatService.sendMessage(chatId, text, senderId);
  }
}
