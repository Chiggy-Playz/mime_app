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

extension ColorHelper on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Color get outline => colorScheme.outline;
  Color get outlineVariant => colorScheme.outlineVariant;
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;
  Color get secondary => colorScheme.secondary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get inverseSurface => colorScheme.inverseSurface;
  Color get onInverseSurface => colorScheme.onInverseSurface;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;
  Color get onTertiary => colorScheme.tertiary;
  Color get tertiary => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;
  Color get surfaceVariant => colorScheme.surfaceVariant;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get surfaceTint => colorScheme.surfaceTint;
  Color get background => colorScheme.background;
  Color get onBackground => colorScheme.onBackground;
  Color get error => colorScheme.error;
  Color get shadow => colorScheme.shadow;
  Color get errorContainer => colorScheme.errorContainer;
  Color get onError => colorScheme.onError;
  Color get onErrorContainer => colorScheme.onErrorContainer;
}

extension TextStyleHelper on BuildContext {
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall;
  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;
  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
}

extension TextStyleColorMapping on TextStyle {
  TextStyle onPrimary(BuildContext context) {
    return copyWith(color: context.onPrimary);
  }

  TextStyle onSecondary(BuildContext context) {
    return copyWith(color: context.onSecondary);
  }

  TextStyle onTertiary(BuildContext context) {
    return copyWith(color: context.onTertiary);
  }

  TextStyle onPrimaryContainer(BuildContext context) {
    return copyWith(color: context.onPrimaryContainer);
  }

  TextStyle onSecondaryContainer(BuildContext context) {
    return copyWith(color: context.onSecondaryContainer);
  }

  TextStyle onTertiaryContainer(BuildContext context) {
    return copyWith(color: context.onTertiaryContainer);
  }

  TextStyle onSurface(BuildContext context) {
    return copyWith(color: context.onSurface);
  }
}
