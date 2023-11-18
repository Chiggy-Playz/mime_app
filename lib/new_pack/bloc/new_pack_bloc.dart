import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'new_pack_event.dart';
part 'new_pack_state.dart';

class NewPackBloc extends Bloc<NewPackEvent, NewPackState> {
  NewPackBloc(this._assetsRepository, this._userRepository)
      : super(NewPackInitial()) {
    on<PackSaved>(onPackSaved);
  }

  final UserRepository _userRepository;
  final AssetsRepository _assetsRepository;

  Future<void> onPackSaved(PackSaved event, Emitter<NewPackState> emit) async {
    emit(NewPackLoading());

    final user = _userRepository.user!;
    try {
      await _assetsRepository.createPack(
        user,
        event.name,
        event.trayIconPath,
      );
    } on PackNameConflictException {
      emit(PackNameConflict());
      return;
    } on DatabaseException {
      emit(DatabaseError());
      return;
    } catch (e) {
      emit(UnknownError());
      return;
    }

    emit(NewPackSuccess());
  }
}
