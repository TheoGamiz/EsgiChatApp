import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../chat/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  final User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _friendUidController = TextEditingController();


  HomeScreen() : super();

  @override
  Widget build(BuildContext context) {
    final friendUid = ModalRoute.of(context)!.settings.arguments ?? "";
    if(friendUid != "") {
      _createOrGetRoomDocument(friendUid as String, context, user);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showAddBottomSheet(context);
              },
              child: Text('Ajouter un ami'),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final userDoc = snapshot.data;
                if (!userDoc!.exists) {
                  return Center(child: Text('Utilisateur introuvable'));
                }

                final friends = userDoc['amis'] as List<dynamic>;
                if (friends.isEmpty) {
                  return Center(child: Text('Aucun ami'));
                }

                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friendUid = friends[index] as String;
                    return FriendCard(
                      friendUid: friendUid,
                      user: user,
                      blockedFriends: List.from(userDoc['bloque']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ajouter un ami',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _friendUidController,
                    decoration: InputDecoration(
                      hintText: "Entrez l'id de votre ami",
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      String friendUid = _friendUidController.text;

                      if (friendUid.isNotEmpty) {
                        try {
                          final FirebaseFirestore firestore =
                              FirebaseFirestore.instance;
                          String currentUserId = user?.uid ?? '';

                          await firestore
                              .collection('users')
                              .doc(friendUid)
                              .update({
                            'demandes': FieldValue.arrayUnion([currentUserId]),
                          });

                          Navigator.of(context).pop();
                        } catch (e) {
                          print(
                              'Erreur lors de l\'ajout de la demande d\'ami : $e');
                        }
                      }
                    },
                    child: Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _createOrGetRoomDocument(String friendUid, BuildContext context, User? user) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String roomId = _generateRoomId(user!.uid, friendUid);

    DocumentSnapshot roomSnapshot =
    await firestore.collection('rooms').doc(roomId).get();

    if (roomSnapshot.exists) {
      _navigateToChatScreen(roomId, friendUid, context, user);
    } else {
      Map<String, dynamic> roomData = {
        'roomId': roomId,
        'participants': [user!.uid, friendUid],
      };

      await firestore.collection('rooms').doc(roomId).set(roomData);
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
      });

      _navigateToChatScreen(roomId, friendUid, context, user);
    }
  } catch (e) {
    print('Erreur lors de la création de la room : $e');
  }
}

String _generateRoomId(String userId, String friendUid) {
  List<String> sortedIds = [userId, friendUid]..sort();
  return "${sortedIds[0]}_${sortedIds[1]}";
}

void _navigateToChatScreen(
    String roomId, String friendUid, context, User? user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatPage(
        roomId: roomId,
        friendUid: friendUid,
        userId: user!.uid,
      ),
    ),
  );
}

class FriendCard extends StatelessWidget {
  final String friendUid;
  final User? user;
  final List<String> blockedFriends;

  FriendCard({required this.friendUid, this.user, required this.blockedFriends})
      : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
      FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: GestureDetector(
              onTap: () {},
              child: ListTile(
                title: Text('Erreur chargement'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              title: Text('Chargement...'),
            ),
          );
        }

        final friendDoc = snapshot.data;
        if (!friendDoc!.exists) {
          return Card(
            child: ListTile(
              title: Text('Utilisateur introuvable'),
            ),
          );
        }

        final friendEmail = friendDoc['email'] as String;
        final imageUrl =
            'https://firebasestorage.googleapis.com/v0/b/chat-app-4c9df.appspot.com/o/${friendUid}.png?alt=media';

        return Card(
          child: GestureDetector(
            onTap: () {
              _createOrGetRoomDocument(friendUid, context, user);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 20, // Adjust the size as needed
              ),
              title: Text(friendEmail),
              // Display any other friend information here, such as name, profile picture, etc.
              trailing: IconButton(
                  icon: Icon(Icons.block),
                  color: blockedFriends.contains(friendUid) ? Colors.red : null,
                  onPressed: () async {
                    final FirebaseFirestore firestore =
                        FirebaseFirestore.instance;

                    if (blockedFriends.contains(friendUid)) {
                      // If the friend is already blocked, remove them from the 'bloque' array.
                      await firestore
                          .collection('users')
                          .doc(user?.uid)
                          .update({
                        'bloque': FieldValue.arrayRemove([friendUid]),
                      });
                    } else {
                      // If the friend is not blocked, add them to the 'bloque' array.
                      await firestore
                          .collection('users')
                          .doc(user?.uid)
                          .update({
                        'bloque': FieldValue.arrayUnion([friendUid]),
                      });
                    }
                  }),
            ),
          ),
        );
      },
    );
  }
}