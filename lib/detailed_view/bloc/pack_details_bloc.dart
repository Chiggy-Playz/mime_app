import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pack_details_event.dart';
part 'pack_details_state.dart';

class PackDetailsBloc extends Bloc<PackDetailsEvent, PackDetailsState> {
  // If asset id is in set, it is selected
  Set<int> selectedAssets = {};
  bool selectMode = false;

  PackDetailsBloc() : super(PackDetailsInitial()) {
    on<AssetSelected>(onAssetSelected);
  }

  void onAssetSelected(AssetSelected event, Emitter<PackDetailsState> emit) {
    final assetId = event.assetId;
    final selected = event.selected;
    if (selected) {
      selectedAssets.add(assetId);
    } else {
      selectedAssets.remove(assetId);
      if (selectedAssets.isEmpty) {
        selectMode = false;
      }
    }
    emit(PackDetailsState(Set.from(selectedAssets), selectMode));
  }

  void toggleSelectMode() {
    selectMode = !selectMode;
  }

}
