part of 'friendlist_bloc.dart';

enum FriendlistStatus {
  initial,
  fetchingFriends,
  addingFriend,
  removingFriend,
  fetchedFriends,
  addedFriend,
  removedFriend,
  errorFetchingFriends,
  errorAddingFriend,
  errorRemovingFriend,
}

class FriendlistState extends Equatable {
  final FriendlistStatus status;
  final List<User> friends;

  const FriendlistState({
    this.status = FriendlistStatus.initial,
    this.friends = const <User>[],
  });

  FriendlistState copyWith({
    FriendlistStatus? status,
    List<User>? friends,
  }) {
    return FriendlistState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
    );
  }

  @override
  List<Object?> get props => [status, friends];
}