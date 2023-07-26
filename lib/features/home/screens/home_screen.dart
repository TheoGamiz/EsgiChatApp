import 'package:esgi_chat_app/app/app_router.dart';
import 'package:esgi_chat_app/features/login/bloc/login_bloc.dart';
import 'package:esgi_chat_app/features/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_state.dart';

import '../../login/screens/login_screen.dart';
import '../../repository/user_repository.dart';
import '../../test/rooms.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

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
      body: Center(child: Text("Loading")),
    );
  }
}