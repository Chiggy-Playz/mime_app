import 'dart:async';

import 'package:assets_repository/assets_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:downloads_repository/downloads_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_repository/user_repository.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final UserRepository _userRepository;
  final AssetsRepository _assetsRepository;
  final DownloadsRepository _downloadsRepository;

  Map<Pack, bool> packsLoaded = {};
  List<Pack> get packs => List.from(packsLoaded.keys);

  StreamSubscription<List<Pack>>? _packsSubscription;

  HomePageBloc(
      {required UserRepository userRepository,
      required AssetsRepository assetsRepository,
      required DownloadsRepository downloadsRepository})
      : _userRepository = userRepository,
        _assetsRepository = assetsRepository,
        _downloadsRepository = downloadsRepository,
        super(HomePageInitial()) {
    // Event handler
    on<HomePageStarted>(onLoad);
    on<HomePageRefreshed>(onLoad);
    on<HomePageRebuild>(onRebuild);

    _packsSubscription = _assetsRepository.packsStream.listen(onPacksUpdate);
  }

  void onPacksUpdate(List<Pack> newPacks) {
    packsLoaded = {
      if (_assetsRepository.unassignedAssetsPack!.isNotEmpty)
        _assetsRepository.unassignedAssetsPack!: true,
      ..._assetsRepository.packs.asMap().map((i, e) => MapEntry(e, true))
    };

    add(HomePageRebuild());
  }

  Future<void> onLoad(event, emit) async {
    final user = _userRepository.user!;
    final unassignedAssetsPack = await _assetsRepository.fetchUnassignedPack();
    final packs = await _assetsRepository.fetchPacks();

    // To shimmer exact number of packs
    packsLoaded = {
      if (unassignedAssetsPack.assets.isNotEmpty) unassignedAssetsPack: false,
      ...packs.asMap().map((key, value) => MapEntry(value, false))
        ..removeWhere((key, value) => key.assets.isEmpty),
    };

    emit(HomePageState(
      userAvatarUrl: user.avatarUrl,
      packsLoaded: Map<Pack, bool>.from(packsLoaded),
    ));

    // Now we download assets based by sticker pack

    final cacheDir = await getApplicationCacheDirectory();

    // Loop through all packs and unasigned assets
    // Find the assets that are not downloaded
    // Download them
    // Once downloaded, emit a state
    for (var pack in [
      if (unassignedAssetsPack.assets.isNotEmpty) unassignedAssetsPack,
      ...packs
    ]) {
      var assetsToDownload = <Asset>[];

      for (final asset in pack.assets) {
        final file = asset.file(cacheDir);
        if (!await file.exists()) {
          assetsToDownload.add(asset);
        }
      }

      await _downloadsRepository.downloadAssets(
        assetsToDownload,
        cacheDir,
      );
      packsLoaded[pack] = true;
      emit(HomePageState(
        userAvatarUrl: user.avatarUrl,
        packsLoaded: Map<Pack, bool>.from(packsLoaded),
      ));
    }

    emit(HomePageState(
      userAvatarUrl: user.avatarUrl,
      packsLoaded: Map<Pack, bool>.from(packsLoaded),
    ));
  }

  Future<void> onRebuild(event, emit) async {
    emit(HomePageState(
      userAvatarUrl: state.userAvatarUrl,
      packsLoaded: Map<Pack, bool>.from(packsLoaded),
    ));
  }

  @override
  Future<void> close() {
    _packsSubscription?.cancel();
    return super.close();
  }
}
