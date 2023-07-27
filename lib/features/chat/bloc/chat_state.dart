import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<types.Message> messages;

  ChatMessagesLoaded({required this.messages});
}

class ChatMessageSent extends ChatState {}

class ChatBlockedStateUpdated extends ChatState {
  final bool isBlocked;

  ChatBlockedStateUpdated({required this.isBlocked});
}

class ChatError extends ChatState {
  final String message;

  ChatError({required this.message});
}
