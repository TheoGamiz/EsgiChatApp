import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:meta/meta.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState());

  @override
  Stream<ChatState> mapEventToState(
      ChatEvent event,
      ) async* {
    if (event is LoadChat) {
      yield* _mapLoadChatToState(event);
    }
    // Handle other events if needed
  }

  Stream<ChatState> _mapLoadChatToState(LoadChat event) async* {
    yield state.copyWith(status: ChatStatus.loading);
    try {
      final messages = await _loadChatMessages(event.roomId);
      if(messages.isEmpty){
        yield state.copyWith(status: ChatStatus.error, error: "Aucun message");
      } else {
        yield state.copyWith(status: ChatStatus.success);
      }
    } catch (e) {
      yield state.copyWith(status: ChatStatus.error);  //ChatState(message: e.toString());
    }
  }

  // Replace this method with actual logic to load chat messages from your data source
  Future<List<types.Message>> _loadChatMessages(String roomId) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading delay

    // Return some dummy data for testing
    return [
      types.TextMessage(
        author: types.User(id: 'user1'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: '1',
        text: 'Hello!',
      ),
      types.TextMessage(
        author: types.User(id: 'user2'),
        createdAt: DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch,
        id: '2',
        text: 'Hi!',
      ),
      // Add more messages as needed
    ];
  }
}
