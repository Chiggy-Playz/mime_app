part of 'pack_selector_bloc.dart';

class PackSelectorState extends Equatable {
  const PackSelectorState(
    this.allPacks,
    this.selectedPacks,
    this.selectMode,
  );
  
  final List<Pack> allPacks;
  final Set<int> selectedPacks;
  final bool selectMode;

  @override
  List<Object> get props => [];
}

class PackSelectorInitial extends PackSelectorState {
  PackSelectorInitial() : super([], {}, false);
}
