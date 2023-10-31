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

  @override
  List<Object?> get props => [packId];
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
}
