part of 'pack_details_bloc.dart';

class PackDetailsState extends Equatable {
  const PackDetailsState(this.pack, this.selectedAssets, this.selectMode);

  final Pack pack;
  final Set<int> selectedAssets;
  final bool selectMode;

  double paddingValue(int id) {
    return selectedAssets.contains(id) ? 14.0 : 0.0;
  }

  @override
  List<Object> get props => [pack, selectedAssets, selectMode];
}

final class PackDetailsInitial extends PackDetailsState {
  PackDetailsInitial(Pack pack) : super(pack, {}, false);
}

final class AssetTransferSuccess extends PackDetailsState {
  const AssetTransferSuccess(
      Pack pack, Set<int> selectedAssets, bool selectMode, this.copy)
      : super(pack, selectedAssets, selectMode);
  final bool copy;
}

final class AssetDeleteSuccess extends PackDetailsState {
  const AssetDeleteSuccess(Pack pack, Set<int> selectedAssets, bool selectMode)
      : super(pack, selectedAssets, selectMode);
}

// No re-build states
final class PackDetailsNoBuild extends PackDetailsState {
  PackDetailsNoBuild() : super(Pack.empty(), {}, false);
}

final class PackDetailsLoading extends PackDetailsNoBuild {
  PackDetailsLoading();
}

final class PackDeleted extends PackDetailsNoBuild {
  PackDeleted();
}

final class PackSynced extends PackDetailsNoBuild {
  PackSynced();
}

// Errors
final class PackDetailsError extends PackDetailsNoBuild {}

final class AnimatedAssetError extends PackDetailsError {
  AnimatedAssetError(this.errorPack);
  final Pack errorPack;
}

final class PackAssetLimitExceededError extends PackDetailsError {
  PackAssetLimitExceededError(this.errorPack);
  final Pack errorPack;
}

final class PackAssetCountLowError extends PackDetailsError {}
