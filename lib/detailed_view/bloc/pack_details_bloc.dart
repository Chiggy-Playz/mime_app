import 'dart:async';

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

  StreamSubscription<List<Pack>>? _packsSubscription;

  final AssetsRepository _assetsRepository;

  PackDetailsBloc(this.pack, this._assetsRepository)
      : super(PackDetailsInitial(pack)) {
    on<PackDetailsRefresh>(onRefresh);
    on<AssetSelected>(onAssetSelected);
    on<SelectAll>(onSelectAll);
    on<DeselectAll>(onDeselectAll);
    on<ToggleSelectMode>(toggleSelectMode);
    on<TransferAssets>(onTransferAssets);
    on<DeleteAssets>(onDeleteAssets);

    _packsSubscription = _assetsRepository.packsStream.listen((newPacks) {
      if (pack.isUnassigned) return;
      add(
        PackDetailsRefresh(
          newPacks.firstWhere(
            (element) => element.packId == pack.packId,
          ),
        ),
      );
    });
  }

  void onRefresh(PackDetailsRefresh event, Emitter<PackDetailsState> emit) {
    pack = event.pack;
    emit(PackDetailsState(event.pack, Set.from(selectedAssets), selectMode));
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

  Future<void> onTransferAssets(
      TransferAssets event, Emitter<PackDetailsState> emit) async {
    emit(PackDetailsLoading());
    try {
      await _assetsRepository.transferAssets(
        assets: event.assets,
        sourcePack: pack,
        destinationPacks: event.destinationPacks.toList(),
        copy: event.copy,
      );
    } on AnimatedAssetPackMixException catch (e) {
      emit(AnimatedAssetError(e.pack));
      return;
    } on PackAssetLimitExceededException catch (e) {
      emit(PackAssetLimitExceededError(e.pack));
      return;
    } catch (e) {
      emit(PackDetailsError());
      return;
    }

    // If transferring from unassigned, refresh the pack manually :(
    if (pack.isUnassigned) {
      pack = _assetsRepository.unassignedAssetsPack!;
    }

    // Set select mode to false
    selectMode = false;
    selectedAssets = {};

    emit(AssetTransferSuccess(
        pack, Set.from(selectedAssets), selectMode, event.copy));
  }

  Future<void> onDeleteAssets(
      DeleteAssets event, Emitter<PackDetailsState> emit) async {
    emit(PackDetailsLoading());
    try {
      await _assetsRepository.deleteAssets(
        assets: event.assets,
        sourcePack: pack,
      );
    } catch (e) {
      emit(PackDetailsError());
      return;
    }

    // If deleting from unassigned, refresh the pack manually :(
    if (pack.isUnassigned) {
      pack = _assetsRepository.unassignedAssetsPack!;
    }

    // Set select mode to false
    selectMode = false;
    selectedAssets = {};

    emit(AssetDeleteSuccess(pack, Set.from(selectedAssets), selectMode));
  }

  @override
  Future<void> close() {
    _packsSubscription?.cancel();
    return super.close();
  }
}
