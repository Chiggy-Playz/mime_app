import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final supabase = Supabase.instance.client;

  AuthenticationRepository() {
    supabase.auth.onAuthStateChange.listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
          _controller.add(AuthenticationStatus.authenticated);
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          _controller.add(AuthenticationStatus.unauthenticated);
          break;
        default:
          break;
      }
    });
  }

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn() async {
    await supabase.auth.signInWithOAuth(Provider.discord);
  }

  void logOut() async {
    _controller.add(AuthenticationStatus.unauthenticated);
    await supabase.auth.signOut();
  }

  void dispose() => _controller.close();
}
