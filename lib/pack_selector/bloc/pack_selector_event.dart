part of 'pack_selector_bloc.dart';

sealed class PackSelectorEvent extends Equatable {
  const PackSelectorEvent();

  @override
  List<Object> get props => [];
}

class PackSelectorStarted extends PackSelectorEvent {
  const PackSelectorStarted();
}

class PacksRefresh extends PackSelectorEvent {
  const PacksRefresh(this.packs);

  final List<Pack> packs;

  @override
  List<Object> get props => [packs];
}

class PackSelected extends PackSelectorEvent {
  const PackSelected(this.pack, this.selected);

  final Pack pack;
  final bool selected;

  @override
  List<Object> get props => [pack, selected];
}
