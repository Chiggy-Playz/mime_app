part of 'pack_selector_bloc.dart';

class PackSelectorState extends Equatable {
  const PackSelectorState(
    this.allPacks,
    this.selectedPacks,
  );

  final List<Pack> allPacks;
  final Set<int> selectedPacks;

  @override
  List<Object> get props => [allPacks, selectedPacks];
}

class PackSelectorInitial extends PackSelectorState {
  PackSelectorInitial() : super([], {});
}
