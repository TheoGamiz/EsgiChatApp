
import 'package:esgi_chat_app/features/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/features/login/screens/login_screen.dart';
import 'package:esgi_chat_app/features/repository/user_repository.dart';
import 'package:esgi_chat_app/features/widgets/navbar.dart';
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
              debugShowCheckedModeBanner: false,
              initialRoute: NavBar.routeName,//FirebaseAuth.instance.currentUser == null ? LoginScreen.routeName : NavBar.routeName,
              routes: {
                //"/": (context) => FirebaseAuth.instance.currentUser == null ? LoginScreen() : HomeScreen(),
                LoginScreen.routeName: (context) => LoginScreen(),
                NavBar.routeName: (context) => NavBar(),
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
