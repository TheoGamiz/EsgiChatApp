// profile_bloc.dart

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final User user;

  ProfileBloc(this.user) : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is PickImageEvent) {
      yield* _mapPickImageEventToState();
    } else if (event is UploadImageEvent) {
      yield* _mapUploadImageEventToState(event.image);
    } /*else if (event is LogoutEvent) {
      yield ProfileInitial();
    }*/
  }

  Stream<ProfileState> _mapPickImageEventToState() async* {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final selectedImage = File(pickedImage.path);
      yield ProfileImagePicked(selectedImage);
    }
  }

  Stream<ProfileState> _mapUploadImageEventToState(File image) async* {
    try {
      final uid = user.uid;
      final firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref('$uid.png');
      await storageRef.putFile(image);
      final downloadURL = await storageRef.getDownloadURL();

      print('Image uploaded. Download URL : $downloadURL');
      yield ProfileImageUploaded(downloadURL);
    } catch (e) {
      print('Error uploading image : $e');
      yield ProfileImageUploadError();
    }
  }
}
