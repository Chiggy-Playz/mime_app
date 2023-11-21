import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'new_pack_event.dart';
part 'new_pack_state.dart';

class NewPackBloc extends Bloc<NewPackEvent, NewPackState> {
  NewPackBloc(
    this._assetsRepository,
  ) : super(NewPackInitial()) {
    on<PackSaved>(onPackSaved);
  }

  final AssetsRepository _assetsRepository;

  Future<void> onPackSaved(PackSaved event, Emitter<NewPackState> emit) async {
    emit(NewPackLoading());

    try {
      await _assetsRepository.createPack(
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
