import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_state.dart';

import '../../chat/screens/chat_screen.dart';
import '../../test/rooms.dart';

class HomeScreen extends StatelessWidget {
  final User? user;
  final TextEditingController _friendUidController = TextEditingController();

  HomeScreen({required this.user}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(AuthenticationLoggedOut());
            },
          ),
        ],
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

void _createOrGetRoomDocument(
    String userId, String friendUid, BuildContext context, User? user) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // First, query the rooms collection to find a room that has both userId and friendUid as participants.
    final QuerySnapshot querySnapshot = await firestore
        .collection('rooms')
        .where('participants', arrayContainsAny: [userId, friendUid]).get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a room already exists with these participants, use that room.
      final roomId = querySnapshot.docs.first.id;
      _navigateToChatScreen(roomId, friendUid, context, user);
    } else {
      // If no room exists, create a new room.
      String roomId = firestore.collection('rooms').doc().id;
      Map<String, dynamic> roomData = {
        'participants': [userId, friendUid]
      };

      await firestore.collection('rooms').doc(roomId).set(roomData);
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'text': 'Message de bienvenue',
        'sender': 'système',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _navigateToChatScreen(roomId, friendUid, context, user);
    }
  } catch (e) {
    print('Erreur lors de la création de la room : $e');
  }
}

void _navigateToChatScreen(
    String roomId, String friendUid, context, User? user) {
  // Navigate to the ChatPage with the roomId and friendUid.
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
                title: Text('Error loading friend'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              title: Text('Loading...'),
            ),
          );
        }

        final friendDoc = snapshot.data;
        if (!friendDoc!.exists) {
          return Card(
            child: ListTile(
              title: Text('Friend not found'),
            ),
          );
        }

        final friendEmail = friendDoc['email'] as String;
        final imageUrl =
            'https://firebasestorage.googleapis.com/v0/b/chat-app-4c9df.appspot.com/o/${friendUid}.png?alt=media';

        return Card(
          child: GestureDetector(
            onTap: () {
              _createOrGetRoomDocument(user!.uid, friendUid, context, user);
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
