import 'package:flutter/foundation.dart';

/// Base exception class for the SpendSum application.
/// Thrown primarily from Data Sources in the Data Layer.
@immutable
class AppException implements Exception {
  final String message;
  final dynamic details;

  const AppException(this.message, {this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Thrown during SQLite local database operations failures.
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.details});
}

/// Thrown during remote network connection or API failures.
class ServerException extends AppException {
  const ServerException(super.message, {super.details});
}
