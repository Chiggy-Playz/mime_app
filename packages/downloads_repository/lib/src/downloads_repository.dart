import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:dio/dio.dart';

class DownloadsRepository {
  late Dio _dio;

  DownloadsRepository() {
    _dio = Dio();
  }

  void dispose() {
    _dio.close();
  }

  Future<void> downloadFile(String url, String savePath) async {
    try {
      await _dio.download(url, savePath);
    } catch (e) {
      throw Exception('Failed to download file');
    }
  }

  Future<void> downloadMultipleFiles(
      Map<String, String> urlsToSavePaths) async {
    if (urlsToSavePaths.isEmpty) return;
    var downloads = <Future>[];

    urlsToSavePaths.forEach((key, value) {
      downloads.add(downloadFile(key, value));
    });

    try {
      await Future.wait(downloads);
    } catch (e) {
      throw Exception('Failed to download files');
    }
  }

  Future<void> downloadAssets(
    List<Asset> assets,
    Directory directory,
  ) async {
    if (assets.isEmpty) return;

    // Downloads assets in webp form for emojis and png for stickers
    await downloadMultipleFiles(
      assets.asMap().map(
            (key, asset) =>
                MapEntry(asset.url, asset.file(directory, true).path),
          ),
    );

    // Once the the assets are downloaded, size them to 512x512 and save them as webp
    for (var asset in assets) {
      String tempPath = asset.file(directory, true).path;
      String outputPath = asset.file(directory).path;
      if (!asset.animated) {
        var session = await FFmpegKit.execute(
            '-i $tempPath -y -vf "scale=512:512:force_original_aspect_ratio=decrease,pad=512:512:-1:-1:color=#00000000" -vcodec webp -pix_fmt yuva420p $outputPath');
        // Console output generated for this execution
        final output = await session.getOutput();
        print(output);
      } else {
        // Animated asset. Convert to gif to webp using ffmpeg
        await FFmpegKit.execute(
            '-i $tempPath -y -vf "scale=512:512:force_original_aspect_ratio=decrease:flags=lanczos,split [a][b]; [a] palettegen=reserve_transparent=on:transparency_color=ffffff [p]; [b][p] paletteuse=sierra2_4a,pad=512:512:-1:-1:color=#00000000" -vcodec webp -pix_fmt yuva420p -quality 60 -loop 0 $outputPath');
      }

      // Delete temp file
      await File(tempPath).delete();
    }
  }
}
