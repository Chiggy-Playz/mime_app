import 'dart:async';

import 'package:assets_repository/assets_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:user_repository/user_repository.dart';

class AssetsRepository {
  final supabase = sp.Supabase.instance.client;
  List<Pack> packs = [];
  Pack? unassignedAssetsPack;

  Future<Pack> fetchUnassignedPack(User user) async {
    var response = await supabase
        .from("unassigned_assets")
        .select<List<Map<String, dynamic>>>('asset_id, assets(type, animated)')
        .eq("user_id", user.id);

    unassignedAssetsPack = Pack(
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

    return unassignedAssetsPack!;
  }

  Future<List<Pack>> fetchPacks(User user) async {
    // Fetch all packs
    // Literally magic!!!
    var response = await supabase
        .from("packs")
        .select<List<Map<String, dynamic>>>(
            'pack_id, name, identifier, user_id, assets(id, type, animated)')
        .eq("user_id", user.id);

    packs = List<Pack>.from(response.map((pack) => Pack.fromMap(pack)));

    return packs;
  }

  Future<Pack> createPack(User user, String name, String iconPath) async {
    try {
      // Insert into database
      var response = await (supabase
          .from("packs")
          .insert({"name": name, "user_id": user.id}));
      // Do something with the icon (not sure how im gonna handle this yet so leaving it blank rn

      // Create pack object
      var pack = Pack(
        identifier: response.data![0]["identifier"],
        name: name,
        packId: response.data![0]["pack_id"],
        userId: user.id,
        assets: [],
      );

      // Add pack to list
      packs.add(pack);

      // Return pack
      return pack;
    } catch (e) {
      throw Exception();
    }
  }
}
