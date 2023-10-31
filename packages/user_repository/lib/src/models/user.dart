import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
      {required this.id, required this.username, required this.avatarUrl});

  final int id;
  final String username;
  final String avatarUrl;

  static const empty = User(id: 0, username: "", avatarUrl: "");

  @override
  List<Object?> get props => [id];

}
