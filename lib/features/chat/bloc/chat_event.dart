part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

// Cet événement est utilisé pour charger les messages du chat à partir de la source de données.
class LoadChat extends ChatEvent {
  final String roomId;

  LoadChat(this.roomId);
}

// Vous pouvez ajouter d'autres événements ici en fonction de vos besoins.
// Par exemple, si vous souhaitez envoyer un message, supprimer un message, mettre à jour un message, etc.
