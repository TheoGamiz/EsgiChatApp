import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

part 'friendlist_event.dart';
part 'friendlist_state.dart';

class FriendlistBloc extends Bloc<FriendlistEvent, FriendlistState> {
  final FriendsRepository friendsRepository;

  FriendlistBloc({
    required this.friendsRepository,
  }) : super(FriendlistState());

  @override
  Stream<FriendlistState> mapEventToState(FriendlistEvent event) async* {
    if (event is AddFriendEvent) {
      yield* _mapAddFriendEventToState(event);
    } else if (event is RemoveFriendRequestEvent) {
      yield* _mapRemoveFriendRequestEventToState(event);
    }
  }

  Stream<FriendlistState> _mapAddFriendEventToState(AddFriendEvent event) async* {
    try {
      await addFriend(event.friendUid);
      yield state.copyWith(status: FriendlistStatus.addedFriend);
    } catch (e) {
      yield state.copyWith(status: FriendlistStatus.errorAddingFriend);
    }
  }

  Stream<FriendlistState> _mapRemoveFriendRequestEventToState(RemoveFriendRequestEvent event) async* {
    try {
      await removeFriendRequest(event.email);
      yield state.copyWith(status: FriendlistStatus.removedFriend);
    } catch (e) {
      yield state.copyWith(status: FriendlistStatus.errorRemovingFriend);
    }
  }
}
