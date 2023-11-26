part of 'pack_details_bloc.dart';

sealed class PackDetailsEvent extends Equatable {
  const PackDetailsEvent();

  @override
  List<Object> get props => [];
}

class PackDetailsRefresh extends PackDetailsEvent {
  const PackDetailsRefresh(this.pack);

  final Pack pack;

  @override
  List<Object> get props => [pack];
}

class AssetSelected extends PackDetailsEvent {
  const AssetSelected(this.assetId, this.selected);

  final int assetId;
  final bool selected;

  @override
  List<Object> get props => [assetId, selected];
}

class ToggleSelectMode extends PackDetailsEvent {}

class SelectAll extends PackDetailsEvent {}

class DeselectAll extends PackDetailsEvent {}

class TransferAssets extends PackDetailsEvent {
  const TransferAssets(this.destinationPacks, this.assets, this.copy);

  final List<Pack> destinationPacks;
  final List<Asset> assets;
  final bool copy;

  @override
  List<Object> get props => [destinationPacks, assets, copy];
}

class DeleteAssets extends PackDetailsEvent {
  const DeleteAssets(this.assets);

  final List<Asset> assets;

  @override
  List<Object> get props => [assets];
}

class SyncStickers extends PackDetailsEvent {}

class UpdatePack extends PackDetailsEvent {

  const UpdatePack(this.newName);

  final String newName;
}

class DeletePack extends PackDetailsEvent {}