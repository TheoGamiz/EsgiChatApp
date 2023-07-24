abstract class LoginEvent {
  const LoginEvent();
}

class LoginEmailChange extends LoginEvent {
  final String email;

  LoginEmailChange({this.email});
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  LoginPasswordChanged({this.password});
}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;

  LoginWithCredentialsPressed({this.email, this.password});
}
