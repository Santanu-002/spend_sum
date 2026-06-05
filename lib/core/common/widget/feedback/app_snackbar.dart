import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

part 'app_snackbar_content.dart';

/// Alias for AppSnackbar to support both casing variants.
typedef AppSnackBar = AppSnackbar;

/// Available types for the AppSnackbar.
enum _AppSnackbarType { neutral, success, destructive, pending }

/// A premium, flat snackbar widget conforming to the SpendSum design specifications.
/// 
/// It offers four visual variants:
/// 1. [AppSnackbar.neutral] (Inverse Surface contrast grey)
/// 2. [AppSnackbar.success] (Secondary container green)
/// 3. [AppSnackbar.destructive] (Error container red)
/// 4. [AppSnackbar.pending] (Tertiary container blue)
/// 
/// Designed with no shadows, rounded corners, and customizable trailing actions.
/// Displays only the message string with no leading icons.
class AppSnackbar extends SnackBar {
  const AppSnackbar._({
    required super.content,
    required super.duration,
    super.key,
  }) : super(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.marginPage,
            vertical: 16.0,
          ),
        );

  /// Neutral variant of the AppSnackbar.
  /// 
  /// Typically used for general notifications or info logs.
  factory AppSnackbar.neutral({
    required String message,
    Widget? trailingAction,
    Duration duration = const Duration(seconds: 4),
    Key? key,
  }) {
    return AppSnackbar._(
      key: key,
      duration: duration,
      content: _AppSnackbarContent(
        message: message,
        trailingAction: trailingAction,
        type: _AppSnackbarType.neutral,
      ),
    );
  }

  /// Success variant of the AppSnackbar.
  /// 
  /// Typically used to confirm successful user actions.
  factory AppSnackbar.success({
    required String message,
    Widget? trailingAction,
    Duration duration = const Duration(seconds: 4),
    Key? key,
  }) {
    return AppSnackbar._(
      key: key,
      duration: duration,
      content: _AppSnackbarContent(
        message: message,
        trailingAction: trailingAction,
        type: _AppSnackbarType.success,
      ),
    );
  }

  /// Destructive variant of the AppSnackbar.
  /// 
  /// Typically used to present validation errors or failures.
  factory AppSnackbar.destructive({
    required String message,
    Widget? trailingAction,
    Duration duration = const Duration(seconds: 4),
    Key? key,
  }) {
    return AppSnackbar._(
      key: key,
      duration: duration,
      content: _AppSnackbarContent(
        message: message,
        trailingAction: trailingAction,
        type: _AppSnackbarType.destructive,
      ),
    );
  }

  /// Pending variant of the AppSnackbar.
  /// 
  /// Typically used to show background work or loading states.
  factory AppSnackbar.pending({
    required String message,
    Widget? trailingAction,
    Duration duration = const Duration(seconds: 4),
    Key? key,
  }) {
    return AppSnackbar._(
      key: key,
      duration: duration,
      content: _AppSnackbarContent(
        message: message,
        trailingAction: trailingAction,
        type: _AppSnackbarType.pending,
      ),
    );
  }
}
