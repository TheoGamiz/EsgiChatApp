import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../repository/chat_repository.dart';
import 'chat_event.dart' as chatEvent;
import 'chat_state.dart' as chatState;

class ChatBloc extends Bloc<chatEvent.ChatEvent, chatState.ChatState> {
  final String friendUid;
  final String roomId;
  final String userId;
  final ChatRepository repository;

  ChatBloc({
    required this.friendUid,
    required this.roomId,
    required this.userId,
    required this.repository,
  }) : super(chatState.ChatInitial());

  @override
  Stream<chatState.ChatState> mapEventToState(
      chatEvent.ChatEvent event) async* {
    if (event is chatEvent.LoadMessages) {
      yield* _mapLoadMessagesToState();
    } else if (event is chatEvent.SendMessage) {
      yield* _mapSendMessageToState(event);
    } else if (event is chatEvent.ToggleBlockedState) {
      yield* _mapToggleBlockedStateToState();
    }
  }

  Stream<chatState.ChatState> _mapLoadMessagesToState() async* {
    try {
      final messages = await repository.loadMessages(roomId);
      yield chatState.ChatMessagesLoaded(messages: messages);
    } catch (e) {
      yield chatState.ChatError(message: 'Failed to load messages: $e');
    }
  }

  Stream<chatState.ChatState> _mapSendMessageToState(
      chatEvent.SendMessage event) async* {
    try {
      await repository.sendMessage(roomId, userId, event.message);
      yield chatState.ChatMessageSent();
    } catch (e) {
      yield chatState.ChatError(message: 'Failed to send message: $e');
    }
  }

  Stream<chatState.ChatState> _mapToggleBlockedStateToState() async* {
    try {
      final isBlocked = await repository.toggleBlockedState(roomId, userId);
      yield chatState.ChatBlockedStateUpdated(isBlocked: isBlocked);
    } catch (e) {
      yield chatState.ChatError(message: 'Failed to update blocked state: $e');
    }
  }
}
