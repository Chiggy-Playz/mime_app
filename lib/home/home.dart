import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mime_app/core/extensions/build_context_extensions.dart';
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
  void initState() {
    super.initState();
    context.read<HomePageBloc>().add(HomePageStarted());
  }

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
            body: StickerPackListWidget(packsLoaded: packsLoaded),
            floatingActionButton: Skeleton.keep(
              child: SpeedDial(
                // Styling for m3
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                spacing: 16,
                childMargin: EdgeInsets.zero,
                childPadding: const EdgeInsets.all(8.0),
                icon: Icons.add,
                activeIcon: Icons.close,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.add_box),
                    label: "Create new pack",
                    onTap: () {},
                    foregroundColor: context.colorScheme.primary,
                    labelBackgroundColor: Colors.transparent,
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.add_photo_alternate),
                    label: "Import sticker",
                    onTap: () {},
                    foregroundColor: context.colorScheme.primary,
                    labelBackgroundColor: Colors.transparent,
                  ),
                ],
                onOpen: () {},
                onPress: () async {
                  // Clear cache dir
                  final cacheDir = await getApplicationCacheDirectory();
                  // Delete all files in cache dir
                  for (final file in cacheDir.listSync()) {
                    await file.delete();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
