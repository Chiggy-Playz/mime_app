part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

final class _AuthenticationStatusChanged extends AuthenticationEvent {
  _AuthenticationStatusChanged(this.status);

  final AuthenticationStatus status;
}

final class AuthenticationLoginRequested extends AuthenticationEvent {}

final class AuthenticationLogoutRequested extends AuthenticationEvent {}
