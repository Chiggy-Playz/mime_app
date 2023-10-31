import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Skeleton.keep(child: Text(message)),
      backgroundColor:
          backgroundColor ?? Theme.of(this).snackBarTheme.backgroundColor,
      action: action,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(
        message: message, backgroundColor: Theme.of(this).colorScheme.error);
  }
}