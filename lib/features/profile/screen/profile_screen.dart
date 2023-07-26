import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  const Profile({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      return Column(
        children: [
          SizedBox(height: 100),
          // Afficher l'image dans un cercle
          _imageUrl != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-app-4c9df.appspot.com/o/${widget.user!.uid}.png?alt=media&token=${widget.user!.refreshToken}"),
                )
              : CircularProgressIndicator(), // You can use any other loading indicator
          Text(widget.user!.email!),
          Text(widget.user!.uid),
        ],
      );
    } else {
      return Text('No user available');
    }
  }
}
