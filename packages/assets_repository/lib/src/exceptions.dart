sealed class AssetRepositoryException {}

class PackNameConflictException extends AssetRepositoryException {
  PackNameConflictException(this.name);

  final String name;
}

