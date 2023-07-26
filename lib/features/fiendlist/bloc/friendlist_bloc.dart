import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'friendlist_event.dart';
part 'friendlist_state.dart';

class FriendlistBloc extends Bloc<FriendlistEvent, FriendlistState> {
  FriendlistBloc() : super(FriendlistInitial()) {
    on<FriendlistEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
