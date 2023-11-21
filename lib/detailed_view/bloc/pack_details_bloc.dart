import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pack_details_event.dart';
part 'pack_details_state.dart';

class PackDetailsBloc extends Bloc<PackDetailsEvent, PackDetailsState> {
  // If asset id is in set, it is selected
  Pack pack;
  Set<int> selectedAssets = {};
  bool selectMode = false;

  PackDetailsBloc(this.pack) : super(PackDetailsInitial(pack)) {
    on<AssetSelected>(onAssetSelected);
    on<SelectAll>(onSelectAll);
    on<DeselectAll>(onDeselectAll);
    on<ToggleSelectMode>(toggleSelectMode);
  }

  void onAssetSelected(AssetSelected event, Emitter<PackDetailsState> emit) {
    final assetId = event.assetId;
    final selected = event.selected;
    if (selected) {
      selectedAssets.add(assetId);
    } else {
      selectedAssets.remove(assetId);
      selectMode = selectedAssets.isNotEmpty;
    }
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }

  void toggleSelectMode(
      ToggleSelectMode event, Emitter<PackDetailsState> emit) {
    selectMode = !selectMode;
    selectedAssets = {};
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }

  void onSelectAll(SelectAll event, Emitter<PackDetailsState> emit) {
    selectedAssets = Set.from(pack.assets.map((e) => e.id));
    selectMode = true;
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }

  void onDeselectAll(DeselectAll event, Emitter<PackDetailsState> emit) {
    selectedAssets = {};
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }
}
