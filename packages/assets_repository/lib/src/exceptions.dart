import '../assets_repository.dart';

sealed class AssetRepositoryException {}

class PackNameConflictException extends AssetRepositoryException {
  PackNameConflictException(this.name);

  final String name;
}

class DatabaseException extends AssetRepositoryException {
  DatabaseException();
}

class AnimatedAssetPackMixException extends AssetRepositoryException {
  AnimatedAssetPackMixException(this.pack);

  final Pack pack;
}

class PackAssetLimitExceededException extends AssetRepositoryException {
  PackAssetLimitExceededException(this.pack);

  final Pack pack;
}
