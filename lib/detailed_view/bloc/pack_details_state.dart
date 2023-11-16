part of 'pack_details_bloc.dart';

class PackDetailsState extends Equatable {
  const PackDetailsState(this.selectedAssets, this.selectMode);

  final Set<int> selectedAssets;
  final bool selectMode;

  double paddingValue(int id) {
    return selectedAssets.contains(id) ? 14.0 : 0.0;
  }

  @override
  List<Object> get props => [selectedAssets, selectMode];
}

final class PackDetailsInitial extends PackDetailsState {
  PackDetailsInitial() : super({}, false);
}
