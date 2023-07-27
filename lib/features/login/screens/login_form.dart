import 'package:esgi_chat_app/features/authentication_bloc/authentication_bloc.dart';
import 'package:esgi_chat_app/features/authentication_bloc/authentication_event.dart';
import 'package:esgi_chat_app/features/register/screens/register_screen.dart';
import 'package:esgi_chat_app/features/widgets/navbar.dart';
import '../../widgets/gradient_button.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChange);
    _passwordController.addListener(_onPasswordChange);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Échec de connexion'),
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
                    Text('Connexion en cours...'),
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
          context.read<AuthenticationBloc>().add(AuthenticationLoggedIn());
          NavBar.navigateTo(context);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
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
                      return !state.isEmailValid ? 'Emain incorrect' : null;
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
                      return !state.isPasswordValid ? 'Mot de passe incorrect' : null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GradientButton(
                    width: 160,
                    height: 45,
                    onPressed: () {
                      if (isButtonEnabled(state)) {
                        _onFormSubmitted();
                      }
                    },
                    text: Text(
                      'Se connecter',
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
                  GradientButton(
                    width: 160,
                    height: 45,
                    onPressed: () {
                      RegisterScreen.navigateTo(context);
                    },
                    text: Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChange() {
    BlocProvider.of<LoginBloc>(context).add(LoginEmailChange(email: _emailController.text));
  }

  void _onPasswordChange() {
    BlocProvider.of<LoginBloc>(context).add(LoginPasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() {
    BlocProvider.of<LoginBloc>(context).add(LoginWithCredentialsPressed(
        email: _emailController.text, password: _passwordController.text));
  }
}
