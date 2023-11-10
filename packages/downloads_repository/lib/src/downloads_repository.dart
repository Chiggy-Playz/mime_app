import 'dart:io';

import 'package:assets_repository/assets_repository.dart';
import 'package:fast_image_resizer/fast_image_resizer.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
            (key, asset) => MapEntry(asset.url, asset.file(directory).path),
          ),
    );

    // Once the the assets are downloaded, size them to 512x512 and save them as webp
    for (var asset in assets) {
      final imageBytes = await asset.file(directory).readAsBytes();

      final bytes = await resizeImage(imageBytes, width: 512, height: 512);

      final bytesList = bytes!.buffer.asUint8List();

      var result = await FlutterImageCompress.compressWithList(
        bytesList,
        format: CompressFormat.webp,
      );

      await asset
          .file(directory)
          .writeAsBytes(result, flush: true);
      await asset.file(directory).delete();
    }
  }
}
