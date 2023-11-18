import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:user_repository/src/models/models.dart';

class UserRepository {
  User? user;
  final _supabase = sp.Supabase.instance.client;

  Future<User?> getUser() async {
    if (user != null) return user;

    final currentUser = await _supabase.auth.currentUser;
    if (currentUser == null) return null;
    user = User(
      id: int.parse(currentUser.userMetadata!["provider_id"]),
      username: currentUser.userMetadata!["custom_claims"]["global_name"],
      avatarUrl: currentUser.userMetadata!["avatar_url"],
    );
    return user;
  }

}
