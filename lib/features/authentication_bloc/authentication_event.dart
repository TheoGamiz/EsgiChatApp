import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {}

class AuthenticationLoggedOut extends AuthenticationEvent {}
