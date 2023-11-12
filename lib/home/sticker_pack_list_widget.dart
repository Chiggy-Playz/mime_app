import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/widgets/empty_widget.dart';
import 'package:mime_app/home/sticker_pack_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'bloc/home_page_bloc.dart';

class StickerPackListWidget extends StatefulWidget {
  const StickerPackListWidget({super.key, required this.packsLoaded});

  final Map<Pack, bool> packsLoaded;

  List<Pack> get packs => List.from(packsLoaded.keys);

  @override
  State<StickerPackListWidget> createState() => StickerPackListWidgetState();
}

class StickerPackListWidgetState extends State<StickerPackListWidget> {
  // PackID -> Expanded
  Map<int, bool> expanded = {};

  @override
  void initState() {
    super.initState();
    for (var pack in widget.packs) {
      expanded[pack.packId] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> expansionTiles = [];

    for (var pack in widget.packs) {
      expansionTiles.add(
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 8,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              expansionTileTheme: ExpansionTileThemeData(
                tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
                childrenPadding: EdgeInsets.symmetric(horizontal: 4.w),
              ),
            ),
            child: ExpansionTile(
                title: Skeleton.keep(
                  keep: widget.packsLoaded[pack]!,
                  child: Text(pack.name,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                initiallyExpanded: true,
                children: [
                  Skeleton.keep(
                    keep: widget.packsLoaded[pack]!,
                    child: StickerPackWidget(
                      pack: pack,
                    ),
                  ),
                ]),
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
          child: ListTileTheme(
            contentPadding: const EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            minVerticalPadding: 0,
            minLeadingWidth: 0,
            child: widget.packs.isEmpty
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
                    itemCount: widget.packs.length,
                    itemBuilder: (context, index) {
                      return expansionTiles[index];
                    },
                  ),
          )),
    );
  }
}
