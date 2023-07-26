import 'package:esgi_chat_app/features/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login/screens/login_screen.dart';

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
              _logOut(context);
            },
          )
        ],
      ),
      body: Center(child: Text("Loading")),
    );
  }

  void _logOut(BuildContext context) {
    LoginScreen.navigateTo(context);
  }
}