import 'dart:io';

import 'package:esgi_chat_app/features/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/features/login/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class Profile extends StatefulWidget {
  Profile() : super();

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _selectedImage;
  final User? user = FirebaseAuth.instance.currentUser!;

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
     try {
      final uid = user!.uid;
      final firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref('$uid.png');
      await storageRef.putFile(_selectedImage!);
    } catch (e) {
      print('Error uploading image : $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (user != null) {
      String token = user!.refreshToken.toString();
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 100),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-app-4c9df.appspot.com/o/${user!.uid}.png?alt=media&token=${token}"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Modifier l'image"),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.grey[200],
                  child: ListTile(
                    title: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user!.email!),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.grey[200],
                  child: ListTile(
                    title: Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(user!.uid),
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () => _copyToClipboard(user!.uid),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //space max
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(AuthenticationLoggedOut());
                  LoginScreen.navigateTo(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      );
    } else {
      return Text('Utilisateur non connecté');
    }
  }

}
