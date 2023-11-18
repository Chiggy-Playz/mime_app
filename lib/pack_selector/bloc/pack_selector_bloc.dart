import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'pack_selector_event.dart';
part 'pack_selector_state.dart';

class PackSelectorBloc extends Bloc<PackSelectorEvent, PackSelectorState> {
  final UserRepository _userRepository;
  final AssetsRepository _assetsRepository;

  // If pack id is in set, it is selected
  Set<int> selectedPacks = {};
  bool get selectMode => selectedPacks.isNotEmpty;

  PackSelectorBloc(this._assetsRepository, this._userRepository)
      : super(PackSelectorInitial()) {
    on<PackSelectorStarted>(
      (_, emit) => emit(
        PackSelectorState(
          _assetsRepository.packs,
          selectedPacks,
          selectMode,
        ),
      ),
    );

    on<PackSelected>(onPackSelect);

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
      selectMode,
    ));
  }

  Future<void> onNewPack(NewPack event, Emitter<PackSelectorState> emit) async {

    // TODO: Actually do something with the tray icon path

    final pack = await _assetsRepository.createPack(
      _userRepository.user!,
      event.name,
      event.trayIconPath ?? "",
    );

    selectedPacks.add(pack.packId);

    emit(PackSelectorState(
      _assetsRepository.packs,
      selectedPacks,
      selectMode,
    ));
  }

}
