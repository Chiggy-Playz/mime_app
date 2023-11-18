part of 'pack_selector_bloc.dart';

sealed class PackSelectorEvent extends Equatable {
  const PackSelectorEvent();

  @override
  List<Object> get props => [];
}

class PackSelectorStarted extends PackSelectorEvent {
  const PackSelectorStarted();
}

class PackSelected extends PackSelectorEvent {
  const PackSelected(this.packId, this.selected);

  final int packId;
  final bool selected;

  @override
  List<Object> get props => [packId, selected];
}

class NewPack extends PackSelectorEvent {

  const NewPack(this.name, this.trayIconPath);


  final String name;
  final String? trayIconPath;
}
