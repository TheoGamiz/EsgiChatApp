
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_state.dart';
import 'package:esgi_chat_app/features/home/screens/home_screen.dart';
import 'package:esgi_chat_app/features/login/screens/login_screen.dart';
import 'package:esgi_chat_app/features/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => UserRepository(
        //postsDataSource: FirestorePostsDataSource(),
      ),
      child: Builder(
        builder: (context) {
          return BlocProvider(
            create: (context) => AuthenticationBloc(
              userRepository: context.read<UserRepository>(),
            )..add(AuthenticationStarted()),
            child: MaterialApp(
              routes: {
                HomeScreen.routeName: (context) => HomeScreen(),
                //AddPostScreen.routeName: (context) => AddPostScreen(),
              },
              //onGenerateRoute: AppRouter.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}