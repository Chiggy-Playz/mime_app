import 'dart:async';

import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pack_selector_event.dart';
part 'pack_selector_state.dart';

class PackSelectorBloc extends Bloc<PackSelectorEvent, PackSelectorState> {
  final AssetsRepository _assetsRepository;

  StreamSubscription<List<Pack>>? _packsSubscription;

  // If pack id is in set, it is selected
  Set<int> selectedPacks = {};

  PackSelectorBloc(this._assetsRepository) : super(PackSelectorInitial()) {
    _packsSubscription = _assetsRepository.packsStream.listen((newPacks) {
      add(PacksRefresh(newPacks));
    });

    on<PackSelectorStarted>(
      (_, emit) => emit(
        PackSelectorState(
          List<Pack>.from(_assetsRepository.packs),
          selectedPacks,
        ),
      ),
    );

    on<PacksRefresh>((event, emit) {
      emit(
        PackSelectorState(
          event.packs,
          selectedPacks,
        ),
      );
    });

    on<PackSelected>(onPackSelect);
  }

  @override
  Future<void> close() {
    _packsSubscription?.cancel();
    return super.close();
  }

  void onPackSelect(PackSelected event, Emitter<PackSelectorState> emit) {
    final packId = event.packId;
    final selected = event.selected;

    if (selected) {
      selectedPacks.add(packId);
    } else {
      selectedPacks.remove(packId);
    }
    emit(PackSelectorState(
      _assetsRepository.packs,
      selectedPacks,
    ));
  }
}
