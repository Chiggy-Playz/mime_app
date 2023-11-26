import 'dart:async';
import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_repository/user_repository.dart';
import 'package:whatsapp_stickers_handler/exceptions.dart';
import 'package:whatsapp_stickers_handler/whatsapp_stickers_handler.dart';
import 'package:fast_image_resizer/fast_image_resizer.dart';

part 'pack_details_event.dart';
part 'pack_details_state.dart';

class PackDetailsBloc extends Bloc<PackDetailsEvent, PackDetailsState> {
  // If asset id is in set, it is selected
  Pack pack;
  Set<int> selectedAssets = {};
  bool selectMode = false;

  StreamSubscription<List<Pack>>? _packsSubscription;

  final AssetsRepository _assetsRepository;
  final UserRepository _userRepository;

  PackDetailsBloc(this.pack, this._assetsRepository, this._userRepository)
      : super(PackDetailsInitial(pack)) {
    on<PackDetailsRefresh>(onRefresh);
    on<AssetSelected>(onAssetSelected);
    on<SelectAll>(onSelectAll);
    on<DeselectAll>(onDeselectAll);
    on<ToggleSelectMode>(toggleSelectMode);
    on<TransferAssets>(onTransferAssets);
    on<DeleteAssets>(onDeleteAssets);
    on<SyncStickers>(onSyncStickers);
    on<UpdatePack>(onUpdatePack);
    on<DeletePack>(onDeletePack);

    _packsSubscription = _assetsRepository.packsStream.listen((newPacks) {
      var newPack = newPacks.firstWhere(
        (element) => element.packId == pack.packId,
        orElse: () => Pack.empty(),
      );
      if (newPack == Pack.empty()) {
        return;
      }
      add(
        PackDetailsRefresh(newPack),
      );
    });
  }

  void onRefresh(PackDetailsRefresh event, Emitter<PackDetailsState> emit) {
    pack = event.pack;
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
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

  Future<void> onSyncStickers(
      SyncStickers event, Emitter<PackDetailsState> emit) async {
    if (pack.assetCount < 3) {
      emit(PackAssetCountLowError());
      return;
    }

    try {
      final WhatsappStickersHandler whatsappStickersHandler =
          WhatsappStickersHandler();

      final dir = await getApplicationCacheDirectory();

      // Icon handling
      Map<String, List<String>> stickers = <String, List<String>>{};
      final rawImage = await rootBundle.load('assets/icons/icon.png');
      final bytes = await resizeImage(Uint8List.view(rawImage.buffer),
          width: 96, height: 96);
      final trayIcon = File('${dir.path}/icon.png');
      await trayIcon.writeAsBytes(bytes!.buffer.asInt8List(), flush: true);

      // Add all assets to sticker pack
      for (var asset in pack.assets) {
        stickers[WhatsappStickerImageHandler.fromFile(asset.file(dir).path)
            .path] = ["🤓"];
      }

      await whatsappStickersHandler.addStickerPack(
        pack.identifier,
        pack.name,
        _userRepository.user!.username,
        WhatsappStickerImageHandler.fromFile(trayIcon.path).path,
        "",
        "",
        "",
        pack.isAnimated,
        stickers,
      );
    } on WhatsappStickersException catch (e) {
      // Error is raised when the pack is already added, even though assets updated
      if (e.cause == "already_added") {
        emit(PackSynced());
        return;
      }
      emit(PackDetailsError());
      return;
    }
    emit(PackSynced());
  }

  Future<void> onUpdatePack(
      UpdatePack event, Emitter<PackDetailsState> emit) async {
    try {
      await _assetsRepository.updatePack(
        pack: pack,
        name: event.newName,
        iconPath: "",
      );
    } catch (e) {
      emit(PackDetailsError());
      return;
    }
    emit(PackDetailsState(pack, Set.from(selectedAssets), selectMode));
  }

  Future<void> onDeletePack(
      DeletePack event, Emitter<PackDetailsState> emit) async {
    try {
      _assetsRepository.deletePack(pack: pack);
    } catch (e) {
      emit(PackDetailsError());
      return;
    }
    emit(PackDeleted());
  }

  @override
  Future<void> close() {
    _packsSubscription?.cancel();
    return super.close();
  }
}
