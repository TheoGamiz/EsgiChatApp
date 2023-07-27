import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key, this.user}) : super(key: key);
  final User? user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _imageUrl;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
     try {
      final uid = widget.user!.uid;
      final firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref('$uid.png');
      await storageRef.putFile(_selectedImage!);
      final downloadURL = await storageRef.getDownloadURL();

      print('Image uploaded. Download URL : $downloadURL');
    } catch (e) {
      print('Error uploading image : $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      String token = widget.user!.refreshToken.toString();
      return Column(
        children: [
          SizedBox(height: 100),
               CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-app-4c9df.appspot.com/o/${widget.user!.uid}.png?alt=media&token=${token}"),
                ),
          Text(widget.user!.email!),
          Text(widget.user!.uid),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Upload Image'),
          ),
        ],
      );
    } else {
      return Text('No user available');
    }
  }
}
