import 'dart:async';

import 'package:assets_repository/assets_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:user_repository/user_repository.dart';

class AssetsRepository {
  final supabase = sp.Supabase.instance.client;
  List<Pack> packs = [];
  Pack? unassignedAssetsPack;
  final UserRepository _userRepository;

  // Streams stuff
  final _packsController = StreamController<List<Pack>>.broadcast();
  Stream<List<Pack>> get packsStream => _packsController.stream;

  final _unassignedAssetsController = StreamController<Pack>.broadcast();
  Stream<Pack> get unassignedAssetsStream => _unassignedAssetsController.stream;

  AssetsRepository(this._userRepository) {}

  void dispose() {
    _packsController.close();
    _unassignedAssetsController.close();
  }

  Future<Pack> fetchUnassignedPack() async {
    var response = await supabase
        .from("unassigned_assets")
        .select<List<Map<String, dynamic>>>('asset_id, assets(type, animated)')
        .eq("user_id", _userRepository.user!.id);

    unassignedAssetsPack = Pack(
      identifier: "\$unassigned\$",
      name: "Unassigned Stickers",
      packId: 0,
      userId: _userRepository.user!.id,
      assets: List<Asset>.from(response.map((a) {
        a["id"] = a.remove("asset_id");
        a.addEntries(a["assets"].entries);
        a.remove("assets");
        return Asset.fromMap(a);
      })),
    );

    return unassignedAssetsPack!;
  }

  Future<List<Pack>> fetchPacks() async {
    // Fetch all packs
    // Literally magic!!!
    var response = await supabase
        .from("packs")
        .select<List<Map<String, dynamic>>>(
            'pack_id, name, identifier, user_id, assets(id, type, animated)')
        .eq("user_id", _userRepository.user!.id);

    packs = List<Pack>.from(response.map((pack) => Pack.fromMap(pack)));

    return packs;
  }

  Future<Pack> createPack(String name, String iconPath) async {
    // Validation
    // Check if pack name already exists
    if (packs.any((pack) => pack.name.toLowerCase() == name.toLowerCase())) {
      throw PackNameConflictException(name);
    }

    try {
      // Insert into database
      var response;
      try {
        response = await (supabase.from("packs").insert({
          "name": name,
          "user_id": _userRepository.user!.id,
          "identifier": name.toLowerCase()
        }).select());
      } catch (e) {
        throw DatabaseException();
      }

      // Do something with the icon (not sure how im gonna handle this yet so leaving it blank rn

      // Create pack object
      var pack = Pack(
        packId: response[0]["pack_id"],
        identifier: name.toLowerCase(),
        name: name,
        userId: _userRepository.user!.id,
        assets: [],
      );

      // Add pack to list
      packs.add(pack);
      _packsController.add(List<Pack>.from(packs));

      // Return pack
      return pack;
    } catch (e) {
      throw Exception("An error occurred while creating the pack");
    }
  }
}
