import 'dart:async';

import 'package:assets_repository/assets_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:user_repository/user_repository.dart';

class AssetsRepository {
  final supabase = sp.Supabase.instance.client;

  List<Pack> _packs = [];
  Pack? _unassignedAssetsPack;

  Future<Pack> getUnassignedPack(User user, [bool force = false]) async {
    // return Pack(
    //   userId: 330810865312071700,
    //   identifier: "\$unassigned\$",
    //   name: "Unassigned Stickers",
    //   packId: 0,
    //   assets: [
    //     Asset(id: 586240877358350341, type: AssetType.emoji, animated: false),
    //     Asset(id: 938503760811012106, type: AssetType.emoji, animated: false),
    //     Asset(id: 814280618959568896, type: AssetType.emoji, animated: false),
    //   ],
    // );

    if ((_unassignedAssetsPack?.assets.isNotEmpty ?? false) && !force)
      return _unassignedAssetsPack!;

    var response = await supabase
        .from("unassigned_assets")
        .select<List<Map<String, dynamic>>>('asset_id, assets(type, animated)')
        .eq("user_id", user.id);

    _unassignedAssetsPack = Pack(
      identifier: "\$unassigned\$",
      name: "Unassigned Stickers",
      packId: 0,
      userId: user.id,
      assets: List<Asset>.from(response.map((a) {
        a["id"] = a.remove("asset_id");
        a.addEntries(a["assets"].entries);
        a.remove("assets");
        return Asset.fromMap(a);
      })),
    );

    return _unassignedAssetsPack!;
  }

  Future<List<Pack>> getPacks(User user, [bool force = false]) async {
    // return [
    //   Pack(
    //     identifier: "testicles",
    //     name: "testicles",
    //     packId: 1,
    //     userId: 330810865312071700,
    //     assets: [
    //       Asset(id: 586240877358350341, type: AssetType.emoji, animated: false),
    //       Asset(id: 938503760811012106, type: AssetType.emoji, animated: false),
    //       Asset(id: 814280618959568896, type: AssetType.emoji, animated: false),
    //     ],
    //   )
    // ];

    if (_packs.isNotEmpty && !force) return _packs;

    // Fetch all packs
    // Literally magic!!!
    var response = await supabase
        .from("packs")
        .select<List<Map<String, dynamic>>>(
            'pack_id, name, identifier, user_id, assets(id, type, animated)')
        .eq("user_id", user.id);

    _packs = List<Pack>.from(response.map((pack) => Pack.fromMap(pack)));

    return _packs;
  }
}
