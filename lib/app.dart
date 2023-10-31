import 'package:assets_repository/assets_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:downloads_repository/downloads_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/authentication/bloc/authentication_bloc.dart';
import 'package:mime_app/home/bloc/home_page_bloc.dart';
import 'package:mime_app/login/login.dart';
import 'package:mime_app/splash.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:user_repository/user_repository.dart';

import 'package:mime_app/home/home.dart';

class MimeApp extends StatefulWidget {
  const MimeApp({super.key});

  @override
  State<MimeApp> createState() => _MimeAppState();
}

class _MimeAppState extends State<MimeApp> {
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final AssetsRepository _assetsRepository;
  late final DownloadsRepository _downloadsRepository;

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository();
    _assetsRepository = AssetsRepository();
    _downloadsRepository = DownloadsRepository();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    _downloadsRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _assetsRepository),
        RepositoryProvider.value(value: _downloadsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthenticationBloc(
              authenticationRepository: _authenticationRepository,
              userRepository: _userRepository,
            ),
          ),
          BlocProvider(
              create: (_) => HomePageBloc(
                    userRepository: _userRepository,
                    assetsRepository: _assetsRepository,
                    downloadsRepository: _downloadsRepository,
                  )),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) => MaterialApp(
        navigatorKey: _navigatorKey,
        routes: {
          "/splash": (context) => const SplashPage(),
          "/login": (context) => const LoginPage(),
          "/home": (context) => const HomePage(),
        },
        initialRoute: "/splash",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        builder: (context, child) {
          return BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              switch (state.status) {
                case AuthenticationStatus.authenticated:
                  _navigator.pushNamedAndRemoveUntil("/home", (route) => false);
                  break;
                case AuthenticationStatus.unauthenticated:
                  _navigator.pushNamedAndRemoveUntil(
                      "/login", (route) => false);
                  break;
                default:
                  break;
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}
