part of 'friendlist_bloc.dart';

abstract class FriendlistEvent {}

class AddFriendEvent extends FriendlistEvent {
  final String friendUid;

  AddFriendEvent(this.friendUid);
}

class RemoveFriendRequestEvent extends FriendlistEvent {
  final String email;

  RemoveFriendRequestEvent(this.email);
}
