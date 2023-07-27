class FriendsRepository {
  Stream<List<User>> getAllFriends() {
    return friendsDataSource.getAllFriends();
  }

  Future<void> addFriend(User friend) async {
    await friendsDataSource.addFriend(friend);
  }

  Future<void> removeFriend(User friend) async {
    await friendsDataSource.removeFriend(friend);
  }
}
