sealed class AssetRepositoryException {}

class PackNameConflictException extends AssetRepositoryException {
  PackNameConflictException(this.name);

  final String name;
}

class DatabaseException extends AssetRepositoryException {
  DatabaseException();
}
