part of 'friendlist_bloc.dart';

abstract class FriendlistState extends Equatable {
  const FriendlistState();

  @override
  List<Object> get props => [];
}

class FriendlistInitial extends FriendlistState {}