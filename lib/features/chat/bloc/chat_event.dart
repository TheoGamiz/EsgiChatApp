abstract class ChatEvent {}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage(this.message);
}

class ToggleBlockedState extends ChatEvent {}
