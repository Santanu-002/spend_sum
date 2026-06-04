import 'package:flutter/foundation.dart';

/// Base sealed class representing logical failures in the Domain and Presentation layers.
/// Handled and mapped in Repositories utilizing the `fpdart` either pattern.
@immutable
sealed class AppFailure {
  final String message;

  const AppFailure(this.message);
}

/// Represents failures originating from database operations.
class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}

/// Represents failures originating from remote network operations.
class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}
