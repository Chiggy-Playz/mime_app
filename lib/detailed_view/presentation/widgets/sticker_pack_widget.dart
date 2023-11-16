import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/extensions/build_context_extensions.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:path_provider/path_provider.dart';

class PackDetailsWidget extends StatefulWidget {
  const PackDetailsWidget({super.key, required this.pack});

  final Pack pack;

  @override
  State<PackDetailsWidget> createState() => _PackDetailsWidgetState();
}

class _PackDetailsWidgetState extends State<PackDetailsWidget> {
  Directory? cacheDir;

  @override
  void initState() {
    super.initState();
    getApplicationCacheDirectory().then((value) => setState(() {
          cacheDir = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (cacheDir == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return BlocBuilder<PackDetailsBloc, PackDetailsState>(
      builder: (context, state) {
        final bloc = BlocProvider.of<PackDetailsBloc>(context);
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          children: List.generate(widget.pack.assets.length, (index) {
            final asset = widget.pack.assets[index];
            bool selected = state.selectedAssets.contains(asset.id);
            var image = Image.file(
              asset.file(cacheDir!),
              fit: BoxFit.fill,
            );

            var imagePaddingValue = selected ? 14.0 : 0.0;
            return GestureDetector(
              onLongPress: () {
                // if already selected, do nothing
                if (selected) return;
                if (!state.selectMode) {
                  bloc.toggleSelectMode();
                }
                bloc.add(AssetSelected(asset.id, true));
              },
              onTap: () {
                // if not in select mode, do nothing
                if (!state.selectMode) return;
                // if already selected, deselect
                bloc.add(AssetSelected(asset.id, !selected));
              },
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  if (state.selectMode && selected)
                    Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(100),
                    ),
                  AnimatedPadding(
                    padding: EdgeInsets.all(imagePaddingValue),
                    duration: const Duration(milliseconds: 150),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(selected ? 12 : 0),
                      child: image,
                    ),
                  ),
                  if (state.selectMode)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color: selected ? context.primary : Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
