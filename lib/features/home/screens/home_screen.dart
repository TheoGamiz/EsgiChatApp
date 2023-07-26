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

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  //final User user;
  //state.firebaseUser

  const HomeScreen(/*{required this.user}*/) : super();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationFailure) {
            return LoginScreen(
              userRepository: context.read<UserRepository>(),
            );
          }

          if (state is AuthenticationSuccess) {
            /*return HomeScreen(
              user: state.firebaseUser,
            );*/
            const RoomsPage();
          }

          return Scaffold(
            appBar: AppBar(),
            body: Container(
              child: Center(child: Text("Loading")),
            ),
          );
        },
      ),//const RoomsPage()//ChatPage(),
    );
  }
}
