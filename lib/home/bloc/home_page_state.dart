part of 'home_page_bloc.dart';

sealed class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

final class HomePageInitial extends HomePageState {}

final class HomePageLoading extends HomePageState {
  final String userAvatarUrl;
  final String userDisplayName;

  final Pack unassignedAssetsPack;
  final List<Pack> packs;

  const HomePageLoading({
    required this.userAvatarUrl,
    required this.userDisplayName,
    required this.unassignedAssetsPack,
    required this.packs,
  });
}

final class HomePageStickerPackLoaded extends HomePageState {
  final Pack loadedPack;

  const HomePageStickerPackLoaded(this.loadedPack);
}

final class HomePageLoaded extends HomePageState {}
