import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key, required this.user}) : super(key: key);
  final User? user;

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friend List')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(widget.user!.uid).snapshots(),
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

          final friendRequests = userDoc['demandes'] as List<dynamic>;
          if (friendRequests.isEmpty) {
            return Center(child: Text('Aucune demande d\'ami'));
          }

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final email = friendRequests[index] as String;

              return Card(
                child: ListTile(
                  title: Text(email),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await addFriend(widget.user!.uid);
                      await removeFriendRequest(email);
                    },
                    child: Text('Ajouter'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> addFriend(String friendUid) async {
    try {
      await usersCollection.doc(widget.user!.uid).update({
        'amis': FieldValue.arrayUnion([friendUid]),
      });
      print('Ami ajouté avec succès.');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'ami: $e');
    }
  }

  Future<void> removeFriendRequest(String email) async {
    try {
      await usersCollection.doc(widget.user!.uid).update({
        'demandes': FieldValue.arrayRemove([email]),
      });
      print('Demande d\'ami supprimée avec succès.');
    } catch (e) {
      print('Erreur lors de la suppression de la demande d\'ami: $e');
    }
  }
}
