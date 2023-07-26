import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
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
                    return FriendCard(friendUid: friendUid, user: user);
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
                            'demande': FieldValue.arrayUnion([currentUserId]),
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

void _createOrGetRoomDocument(String userId, String friendUid) async {
  print("JE CREE UNE ROOM AVANT");

  try {
    print("JE CREE UNE ROOM TRY");
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Générer un nouvel ID pour le document de la room
    String roomId = firestore.collection('rooms').doc().id;

    // Définir les données du document
    Map<String, dynamic> roomData = {
      'participants': [userId, friendUid]
    };

    // Ajouter le document à la collection "rooms"
    await firestore.collection('rooms').doc(roomId).set(roomData);

    // Créer une sous-collection "messages" dans le document de la room
    await firestore.collection('rooms').doc(roomId).collection('messages').add({
      'text': 'Message de bienvenue', // Exemple de message initial
      'sender': 'système', // Exemple de l'expéditeur initial
      'timestamp': FieldValue
          .serverTimestamp(), // Exemple de timestamp avec heure du serveur
    });
  } catch (e) {
    print('Erreur lors de la création de la room : $e');
  }
}

class FriendCard extends StatelessWidget {
  final String friendUid;
  final User? user;

  FriendCard({required this.friendUid, this.user}) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                        friendUid:
                            friendUid), // Pass the friendUid to the ChatPage
                  ),
                );
              },
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
              _createOrGetRoomDocument(user!.uid, friendUid);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                      friendUid:
                          friendUid), // Pass the friendUid to the ChatPage
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 20, // Adjust the size as needed
              ),
              title: Text(friendEmail),
              // Display any other friend information here, such as name, profile picture, etc.
            ),
          ),
        );
      },
    );
  }
}
