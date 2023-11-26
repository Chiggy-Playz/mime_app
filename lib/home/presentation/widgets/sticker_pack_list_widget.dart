import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/widgets/empty_widget.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:mime_app/detailed_view/presentation/screens/pack_details_screen.dart';
import 'package:mime_app/home/bloc/home_page_bloc.dart';
import 'package:mime_app/home/presentation/widgets/sticker_pack_preview_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:user_repository/user_repository.dart';


class StickerPackListWidget extends StatefulWidget {
  const StickerPackListWidget({super.key});

  @override
  State<StickerPackListWidget> createState() => StickerPackListWidgetState();
}

class StickerPackListWidgetState extends State<StickerPackListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, state) {
        List<Widget> packTiles = [];

        for (var pack in state.packs) {
          packTiles.add(
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              elevation: 8,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (creatorContext) => PackDetailsBloc(
                          pack,
                          RepositoryProvider.of<AssetsRepository>(
                              creatorContext),
                          RepositoryProvider.of<UserRepository>(creatorContext),
                        ),
                        child: const PackDetailsScreen(),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      title: Skeleton.keep(
                        keep: state.packsLoaded[pack]!,
                        child: Text(pack.name,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      subtitle: Text("${pack.assets.length} stickers"),
                    ),
                    Skeleton.keep(
                      keep: state.packsLoaded[pack]!,
                      child: StickerPackPreviewWidget(
                        pack: pack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<HomePageBloc>(context).add(
              HomePageRefreshed(),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: state.packs.isEmpty
                ? const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                        SliverFillRemaining(
                          child: EmptyWidget(
                              title: "No stickers yet",
                              icon: Icons.image_not_supported,
                              description:
                                  "You don't have any stickers yet. Get started by creating a new pack or importing from discord!"),
                        ),
                      ])
                : ListView.builder(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    key: UniqueKey(),
                    itemCount: state.packs.length,
                    itemBuilder: (context, index) {
                      return packTiles[index];
                    },
                  ),
          ),
        );
      },
    );
  }
}
