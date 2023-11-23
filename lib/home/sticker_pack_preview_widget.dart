import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StickerPackPreviewWidget extends StatefulWidget {
  const StickerPackPreviewWidget({super.key, required this.pack});

  final Pack pack;

  @override
  State<StickerPackPreviewWidget> createState() =>
      _StickerPackPreviewWidgetState();
}

class _StickerPackPreviewWidgetState extends State<StickerPackPreviewWidget> {
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // We'll show 3 preview stickers and 4th widget will indicate how many stickers are in the pack
        children: [
          for (var asset in widget.pack.assets.take(3))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Skeleton.replace(
                height: 18.w,
                width: 18.w,
                replacement: const Skeleton.shade(child: Card()),
                child: cacheDir == null
                    ? const Skeleton.shade(child: Card())
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(asset.file(cacheDir!)),
                            fit: BoxFit.fill,
                          ),
                        ),
                        width: 18.w,
                        height: 18.w,
                      ),
              ),
            ),
          if (widget.pack.assets.length > 3)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Skeleton.replace(
                height: 18.w,
                width: 18.w,
                replacement: const Skeleton.shade(child: Card()),
                child: cacheDir == null
                    ? const Skeleton.shade(child: Card())
                    : SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: Center(
                          child: Text(
                            "+${widget.pack.assets.length - 3} More",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
