import 'package:firebase_auth/firebase_auth.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_state.dart';

import '../../test/rooms.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  const HomeScreen({required this.user}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add), // Use the '+' icon for the button
              onPressed: () {
                _showAddBottomSheet(context);
                // Add your functionality here when the '+' button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(AuthenticationLoggedOut());
              },
            ),
          ],
        ),
        body: const RoomsPage() //ChatPage(),
        );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Set this to true to enable scrolling
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Insets for the keyboard
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
                    decoration: InputDecoration(
                      hintText: "Entrez l'id de votre ami",
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Add the functionality to handle adding friends here
                      Navigator.of(context).pop(); // To close the bottom sheet
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
