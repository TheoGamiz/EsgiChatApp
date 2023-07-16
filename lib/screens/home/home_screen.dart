import 'package:firebase_auth/firebase_auth.dart';
import 'package:esgi_chat_app/blocs/auth_bloc/bloc/auth_bloc.dart';
import 'package:esgi_chat_app/blocs/auth_bloc/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth_bloc/bloc/auth_state.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseUser user;

  const HomeScreen({ Key? key, required this.user}) : super(key: key);

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
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text("Hello, ${user.email}"),
          ),
        ],
      ),
    );
  }
}
