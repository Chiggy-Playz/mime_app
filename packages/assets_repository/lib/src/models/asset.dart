import 'dart:io';

import 'package:equatable/equatable.dart';

enum AssetType { emoji, sticker }

class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.type,
    required this.animated,
  });

  final int id;
  final AssetType type;
  final bool animated;

  static const empty = Asset(id: 0, type: AssetType.emoji, animated: false);

  @override
  List<Object?> get props => [id];

  String get url {
    if (type == AssetType.emoji) {
      return "https://cdn.discordapp.com/emojis/$id.${extension(true)}?size=512&quality=lossless";
    } else {
      return "https://media.discordapp.net/stickers/${id}.png?size=512";
    }
  }

  File file(Directory directory, {bool compressed = true}) {
    return File(directory.path +
        '/$id.${extension(compressed)}');
  }

  String extension(bool compressed) {
    if (animated) return "gif";
    if (type == AssetType.sticker || !compressed) return "png";
    return "webp";
  }

  factory Asset.fromMap(Map<String, dynamic> json) => Asset(
        id: json["id"],
        type: AssetType.values.byName(json["type"]),
        animated: json["animated"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "type": type.toString(),
        "animated": animated,
      };
}
