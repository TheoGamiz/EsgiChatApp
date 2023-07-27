import 'package:cloud_firestore/cloud_firestore.dart';

class UserFromFriendList {
  final String id;
  final String email;

  const UserFromFriendList({
    required this.id,
    required this.email,
  });

  factory UserFromFriendList.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFromFriendList(
      id: doc.id,
      email: data['email'] ?? '',
    );
  }
}