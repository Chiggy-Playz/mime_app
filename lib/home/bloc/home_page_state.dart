part of 'home_page_bloc.dart';

class HomePageState extends Equatable {
  const HomePageState({required this.userAvatarUrl, required this.packsLoaded});

  final String userAvatarUrl;
  final Map<Pack, bool> packsLoaded;

  List<Pack> get packs => List.from(packsLoaded.keys);
  bool get loading =>
      userAvatarUrl.isEmpty ||
      (packsLoaded.isNotEmpty && packsLoaded.values.any((element) => !element));

  @override
  List<Object> get props => [userAvatarUrl, packsLoaded];
}

final class HomePageInitial extends HomePageState {
  HomePageInitial()
      : super(
          userAvatarUrl: "",
          packsLoaded: {
            Pack(
              identifier: "\$dummmy pack for loading\$",
              name: "dummmy pack for loading",
              packId: 0,
              userId: 0,
              assets: List.generate(10, (index) => Asset.empty),
            ): false,
            Pack(
              identifier: "\$dummmy pack for loading\$",
              name: "dummmy pack for loading",
              packId: 0,
              userId: 0,
              assets: List.generate(14, (index) => Asset.empty),
            ): false,
            Pack(
              identifier: "\$dummmy pack for loading\$",
              name: "dummmy pack for loading",
              packId: 0,
              userId: 0,
              assets: List.generate(14, (index) => Asset.empty),
            ): false,
          },
        );
}
