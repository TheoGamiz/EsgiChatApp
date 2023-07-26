abstract class LoginEvent {
  const LoginEvent();
}

class LoginEmailChange extends LoginEvent {
  final String email;

  LoginEmailChange({required this.email});
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  LoginPasswordChanged({required this.password});
}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;

  LoginWithCredentialsPressed({required this.email, required this.password});
}
