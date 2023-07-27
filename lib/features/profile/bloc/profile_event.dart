// profile_event.dart

part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class PickImageEvent extends ProfileEvent {}

class UploadImageEvent extends ProfileEvent {
  final File image;

  UploadImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class LogoutEvent extends ProfileEvent {}
