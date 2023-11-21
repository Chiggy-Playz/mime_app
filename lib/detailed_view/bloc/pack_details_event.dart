part of 'pack_details_bloc.dart';

sealed class PackDetailsEvent extends Equatable {
  const PackDetailsEvent();

  @override
  List<Object> get props => [];
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