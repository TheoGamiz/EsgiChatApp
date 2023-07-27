import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository({required this.firestore});

  Future<List<types.Message>> loadMessages(String roomId) async {
    final snapshot = await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => types.TextMessage.fromJson(doc.data()))
        .toList();
  }

  Future<void> sendMessage(String roomId, String userId, String message) async {
    await firestore.collection('rooms').doc(roomId).collection('messages').add({
      'text': message,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> toggleBlockedState(String roomId, String userId) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    List<String> noNotifList = List<String>.from(userDoc.get('NoNotif') ?? []);

    if (noNotifList.contains(roomId)) {
      // Supprimer le roomId de la liste
      noNotifList.remove(roomId);
    } else {
      // Ajouter le roomId à la liste
      noNotifList.add(roomId);
    }

    await firestore.collection('users').doc(userId).update({
      'NoNotif': noNotifList,
    });

    return noNotifList.contains(roomId);
  }
}
