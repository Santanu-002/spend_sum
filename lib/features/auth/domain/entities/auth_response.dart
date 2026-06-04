import 'package:equatable/equatable.dart';

/// Representation of verified authentication result.
class AuthResponse extends Equatable {
  final String uid;
  final bool isNew;
  final bool isBudgetCompleted;

  const AuthResponse({
    required this.uid,
    required this.isNew,
    required this.isBudgetCompleted,
  });

  @override
  List<Object?> get props => [uid, isNew, isBudgetCompleted];
}
