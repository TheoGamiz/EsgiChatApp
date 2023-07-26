import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  State<Profile> createState() => _ProfileState();
}


Future<String?> _getImageUrl(user) async {
  if (user != null) {
    try {
      // Assuming you have a Firebase Storage bucket named "profile_pictures"
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user!.uid}');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  } else {
    return null;
  }
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    
    if (widget.user != null) {
      return Column(
        children: [
          SizedBox(height: 100),
          // Afficher l'image dans un cercle
          
          
          Text(widget.user!.email!),
          Text(widget.user!.uid),
        ],
      );
    } else {
      return Text('No user available');
    }
  }
}
