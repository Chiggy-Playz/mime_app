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
    } on DatabaseException {
      throw DatabaseException();
    } catch (e) {
      throw Exception("An error occurred while creating the pack");
    }
  }

  Future<Pack> updatePack(
      {required Pack pack,
      required String name,
      required String iconPath}) async {
    try {
      try {
        await (supabase.from("packs").update({
          "name": name,
        }).eq("pack_id", pack.packId));
      } catch (e) {
        throw DatabaseException();
      }

      // Update local packs cache by replacing the old pack with the new one
      var newPack = Pack(
        packId: pack.packId,
        identifier: pack.identifier,
        name: name,
        userId: pack.userId,
        assets: pack.assets,
      );
      packs.removeWhere((p) => p.packId == pack.packId);
      packs.add(newPack);
      _packsController.add(List<Pack>.from(packs));

      return newPack;
    } on DatabaseException {
      throw DatabaseException();
    } catch (e) {
      throw Exception("An error occurred while updating the pack");
    }
  }

  Future<void> transferAssets(
      {required List<Asset> assets,
      required Pack sourcePack,
      required List<Pack> destinationPacks,
      required bool copy}) async {
    // Check if we're trying to add animated assets to a non-animated pack
    // Or vice-versa
    // Check if any pack goes over 30 assets
    for (var pack in destinationPacks) {
      if (pack.isEmpty) continue;

      if (pack.isAnimated && assets.any((asset) => !asset.animated)) {
        throw AnimatedAssetPackMixException(pack);
      }
      if (!pack.isAnimated && assets.any((asset) => asset.animated)) {
        throw AnimatedAssetPackMixException(pack);
      }
      if (pack.assetCount + assets.length > 30) {
        throw PackAssetLimitExceededException(pack);
      }
    }

    // Actually transfer the assets
    for (var destinationPack in destinationPacks) {
      await (supabase.from("pack_contents").upsert(assets
          .map((asset) => {
                "pack_id": destinationPack.packId,
                "asset_id": asset.id,
              })
          .toList()));
    }

    if (!copy) {
      // When moving, remove the assets from the original pack
      if (sourcePack.isUnassigned) {
        await (supabase
            .from("unassigned_assets")
            .delete()
            .in_("asset_id", assets.map((asset) => asset.id).toList())
            .eq("user_id", _userRepository.user!.id));
      } else {
        await (supabase
            .from("pack_contents")
            .delete()
            .in_("asset_id", assets.map((asset) => asset.id).toList())
            .eq("pack_id", sourcePack.packId));
      }
    }

    // Update the local packs cache
    for (var destinationPack in destinationPacks) {
      // Update local packs cache
      for (var pack in this.packs) {
        // Add to destination pack
        if (pack.packId == destinationPack.packId) {
          pack.assets.addAll(assets);
          break;
        }
        // If we're moving, remove from source pack
        if (!copy && pack.packId == sourcePack.packId) {
          pack.assets.removeWhere((asset) => assets.contains(asset));
          break;
        }
      }
    }
    _packsController.add(List<Pack>.from(packs));
    if (!copy) {
      // If we're moving from unassigned pack, remove from unassigned pack
      if (sourcePack.isUnassigned) {
        unassignedAssetsPack!.assets
            .removeWhere((asset) => assets.contains(asset));
        _unassignedAssetsController.add(unassignedAssetsPack!);
      }
    }
  }

  Future<void> deleteAssets(
      {required List<Asset> assets, required Pack sourcePack}) async {
    // Delete from database
    if (sourcePack.isUnassigned) {
      await (supabase
          .from("unassigned_assets")
          .delete()
          .in_("asset_id", assets.map((asset) => asset.id).toList())
          .eq("user_id", _userRepository.user!.id));
    } else {
      await (supabase
          .from("pack_contents")
          .delete()
          .in_("asset_id", assets.map((asset) => asset.id).toList())
          .eq("pack_id", sourcePack.packId));
    }
    // Update local packs cache
    for (var pack in this.packs) {
      pack.assets.removeWhere((asset) => assets.contains(asset));
    }
    _packsController.add(List<Pack>.from(packs));

    if (sourcePack.isUnassigned) {
      unassignedAssetsPack!.assets
          .removeWhere((asset) => assets.contains(asset));
      _unassignedAssetsController.add(unassignedAssetsPack!);
    }
  }
}
