import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StickerPackWidget extends StatefulWidget {
  const StickerPackWidget({super.key, required this.pack});

  final Pack pack;

  @override
  State<StickerPackWidget> createState() => _StickerPackWidgetState();
}

class _StickerPackWidgetState extends State<StickerPackWidget> {
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
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.h,
        children: [
          for (var asset in widget.pack.assets)
            Skeleton.replace(
              height: 18.w,
              width: 18.w,
              replacement: const Skeleton.shade(child: Card()),
              child: cacheDir == null
                  ? const Skeleton.shade(child: Card())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        asset.file(cacheDir!),
                        height: 18.w,
                        width: 18.w,
                        fit: BoxFit.fill,
                      ),
                    ),
            )
        ],
      ),
    );
  }
}
