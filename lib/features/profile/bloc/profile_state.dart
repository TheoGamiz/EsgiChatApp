// profile_state.dart

part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileImagePicked extends ProfileState {
  final File image;

  ProfileImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

class ProfileImageUploaded extends ProfileState {
  final String downloadURL;

  ProfileImageUploaded(this.downloadURL);

  @override
  List<Object?> get props => [downloadURL];
}

class ProfileImageUploadError extends ProfileState {}
