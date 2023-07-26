part of 'chat_bloc.dart';

/*
@immutable
abstract class ChatState {}

// État initial du chat avant de charger les messages.
class ChatInitial extends ChatState {}

// État lorsque les messages du chat sont en cours de chargement.
class ChatLoading extends ChatState {}

// État lorsque les messages du chat ont été chargés avec succès.
class ChatLoaded extends ChatState {
  final List<types.Message> messages;

  ChatLoaded(this.messages);
}

// État lorsque le chargement des messages du chat a échoué.
class ChatError extends ChatState {
  final String message;

  ChatError({required String this.message});
}*/

// Vous pouvez ajouter d'autres états ici en fonction de vos besoins.
// Par exemple, un état pour indiquer que l'envoi d'un message est en cours, ou que la mise à jour d'un message est en cours, etc.



enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

class ChatState {
  final ChatStatus status;
  final List<Message> messages;
  final String error;

  ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error = '',
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}