import 'package:equatable/equatable.dart';

import 'asset.dart';

class RawPack extends Equatable {
  final int userId;
  final int packId;
  final String name;
  final String identifier;

  RawPack({
    required this.userId,
    required this.packId,
    required this.name,
    required this.identifier,
  });

  factory RawPack.fromMap(Map<String, dynamic> json) => RawPack(
        userId: json["user_id"],
        packId: json["pack_id"],
        name: json["name"],
        identifier: json["identifier"],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "pack_id": packId,
        "name": name,
        "identifier": identifier,
      };

  bool get isUnassigned => packId == 0;

  @override
  List<Object?> get props => [packId, name];
}

class Pack extends RawPack {
  final List<Asset> assets;

  Pack({
    required int userId,
    required int packId,
    required String name,
    required String identifier,
    required this.assets,
  }) : super(
          userId: userId,
          packId: packId,
          name: name,
          identifier: identifier,
        );

  factory Pack.fromMap(Map<String, dynamic> json) => Pack(
        userId: json["user_id"],
        packId: json["pack_id"],
        name: json["name"],
        identifier: json["identifier"],
        assets: List<Asset>.from(json["assets"].map((x) => Asset.fromMap(x))),
      );

  factory Pack.fromRawPack(RawPack rawPack, List<Asset> assets) => Pack(
        userId: rawPack.userId,
        packId: rawPack.packId,
        name: rawPack.name,
        identifier: rawPack.identifier,
        assets: assets,
      );

  factory Pack.empty() => Pack(
        userId: -1,
        packId: -1,
        name: "",
        identifier: "",
        assets: [],
      );

  bool get isEmpty => assets.isEmpty;
  bool get isNotEmpty => assets.isNotEmpty;
  int get assetCount => assets.length;
  bool get isAnimated => assets.any((element) => element.animated);
}
