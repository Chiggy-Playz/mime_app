import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/home/bloc/home_page_bloc.dart';
import 'package:mime_app/home/sticker_pack_list_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appBarTitle = "Loading...";
  String userAvatarUrl = "";

  Map<Pack, bool> packsLoaded = {
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
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePageBloc, HomePageState>(
      listener: (context, state) {
        if (state is HomePageInitial) {
          return;
        }
        appBarTitle = "Your Stickers";
        if (state is HomePageLoading) {
          userAvatarUrl = state.userAvatarUrl;
          packsLoaded = {
            if (state.unassignedAssetsPack.assets.isNotEmpty)
              state.unassignedAssetsPack: false,
            ...state.packs.asMap().map((key, value) => MapEntry(value, false)),
          };
          '';
        } else if (state is HomePageStickerPackLoaded) {
          packsLoaded[state.loadedPack] = true;
        }
      },
      builder: (context, state) {
        final bool loading = state is! HomePageLoaded;

        return Skeletonizer(
          enabled: loading,
          child: Scaffold(
            appBar: AppBar(
              title: Skeleton.keep(child: Text(appBarTitle)),
              leading: Skeleton.replace(
                replacement: Icon(
                  Icons.person,
                  size: 8.w,
                ),
                replace: userAvatarUrl.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userAvatarUrl),
                  ),
                ),
              ),
            ),
            // Check if its initial loading, which means we dont even know how many packs there are
            body: StickerPackListWidget(
                packsLoaded:
                    packsLoaded), // true  ? skeletalView() : const Center(child: Text("Home")),
            floatingActionButton: Skeleton.keep(
              child: FloatingActionButton(
                onPressed: () async {
                  // Clear all files in cache dir
                  final cacheDir = await getApplicationCacheDirectory();
                  for (var file in cacheDir.listSync()) {
                    await file.delete();
                  }
                },
                child: const Icon(Icons.logout),
              ),
            ),
          ),
        );
      },
    );
  }
}
