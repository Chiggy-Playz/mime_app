import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/authentication/bloc/authentication_bloc.dart';
import 'package:mime_app/utils/extensions.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mime"),
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationLoginInProgress) {
            // Show a loading indicator while the user waits
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state.status == AuthenticationStatus.authenticated) {
            // Show snackbar when the user is authenticated
            context.showSnackBar(message: "Welcome ${state.user.username}!");
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Welcome!",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "To get started, connect your discord account to Mime.",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AuthenticationBloc>()
                      .add(AuthenticationLoginRequested());
                },
                icon: const Image(
                  image: AssetImage("assets/discord_icon.png"),
                  height: 50,
                ),
                label: const Text("Connect Discord", textScaleFactor: 1.3),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
