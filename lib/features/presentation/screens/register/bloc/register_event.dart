abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  RegisterEmailChanged({required this.email});
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  RegisterPasswordChanged({required this.password});
}

class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String password;

  RegisterSubmitted({required this.email, required this.password});
}
