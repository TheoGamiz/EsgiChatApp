import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthenticationState {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final User firebaseUser;

  AuthenticationSuccess(this.firebaseUser);
}

class AuthenticationFailure extends AuthenticationState {}
