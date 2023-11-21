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

  HomePageBloc(
      {required UserRepository userRepository,
      required AssetsRepository assetsRepository,
      required DownloadsRepository downloadsRepository})
      : _userRepository = userRepository,
        _assetsRepository = assetsRepository,
        _downloadsRepository = downloadsRepository,
        super(HomePageInitial()) {
    // Event handler
    on<HomePageStarted>(load);
    on<HomePageRefreshed>(load);
  }

  Future<void> load(event, emit) async {
    final user = _userRepository.user!;
    final unassignedAssets =
        await _assetsRepository.fetchUnassignedPack();
    final packs = await _assetsRepository.fetchPacks();

    // To shimmer exact number of packs
    emit(HomePageLoading(
      userDisplayName: user.username,
      userAvatarUrl: user.avatarUrl,
      unassignedAssetsPack: unassignedAssets,
      packs: packs,
    ));

    // Now we download assets based by sticker pack

    final cacheDir = await getApplicationCacheDirectory();

    // Loop through all packs and unasigned assets
    // Find the assets that are not downloaded
    // Download them
    // Once downloaded, emit a state
    for (var pack in [
      if (unassignedAssets.assets.isNotEmpty) unassignedAssets,
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

      emit(HomePageStickerPackLoaded(pack));
    }
    // Once all of them are downloaded, emit a final state
    emit(HomePageLoaded());
  }
}
