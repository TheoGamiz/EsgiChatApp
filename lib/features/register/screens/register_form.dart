import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/blocs/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/features/widgets/gradient_button.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  late RegisterBloc _registerBloc;

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChange);
    _passwordController.addListener(_onPasswordChange);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Échec de l\'inscription'),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Color(0xffffae88),
              ),
            );
        }

        if (state.isSubmitting) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Inscription en cours...'),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  ],
                ),
                backgroundColor: Color(0xffffae88),
              ),
            );
        }

        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(
            AuthenticationLoggedIn(),
          );
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'Email invalide' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: "Mot de passe",
                    ),
                    obscureText: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isPasswordValid
                          ? 'Mot de passe invalide'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GradientButton(
                    width: 150,
                    height: 45,
                    onPressed: () {
                      _onFormSubmitted();
                      print("HELLO");
                    },
                    text: Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onEmailChange() {
    _registerBloc.add(RegisterEmailChanged(email: _emailController.text));
  }

  void _onPasswordChange() {
    _registerBloc
        .add(RegisterPasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() async {
    if (true) {
      try {
        // Récupérer l'e-mail et le mot de passe des contrôleurs
        String email = _emailController.text;
        String password = _passwordController.text;

        // Créer l'utilisateur dans Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Récupérer l'identifiant de l'utilisateur depuis userCredential
        String userId = userCredential.user!.uid;
         final _firebaseMessaging = FirebaseMessaging.instance;

  
        await _firebaseMessaging.requestPermission();
        String? token = await _firebaseMessaging.getToken();

        // Créer une carte avec les informations de l'utilisateur
        Map<String, dynamic> userInfo = {
          'email': email,
          'createdAt':
              DateTime.now(),
            'demandes': [],
            'amis' : [],
            'token': token// Facultatif : stocker l'heure de création
          // Ajouter toute autre information que vous souhaitez stocker
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(userInfo);

        // Envoyer l'événement à AuthenticationBloc pour mettre à jour son état
        BlocProvider.of<AuthenticationBloc>(context).add(
          AuthenticationLoggedIn(),
        );

        // Naviguer vers l'écran précédent
        Navigator.pop(context);
      } catch (e) {
        // Gérer les erreurs survenues lors de l'inscription
        print("Erreur d'inscription : $e");
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Erreur d\'inscription'),
                  Icon(Icons.error),
                ],
              ),
              backgroundColor: Color(0xffffae88),
            ),
          );
      }
    }
  }
}
