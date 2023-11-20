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
  }

  void onAssetSelected(AssetSelected event, Emitter<PackDetailsState> emit) {
    final assetId = event.assetId;
    final selected = event.selected;
    if (selected) {
      selectedAssets.add(assetId);
    } else {
      selectedAssets.remove(assetId);
    }
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }

  void toggleSelectMode() {
    selectMode = !selectMode;
  }
}
