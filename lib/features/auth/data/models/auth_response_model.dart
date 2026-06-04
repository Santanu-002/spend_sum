import 'package:spend_sum/features/auth/domain/entities/auth_response.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.uid,
    required super.isNew,
    required super.isBudgetCompleted,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'uid': String uid,
        'isNew': bool isNew,
        'isBudgetCompleted': bool isBudgetCompleted,
      } =>
        AuthResponseModel(
          uid: uid,
          isNew: isNew,
          isBudgetCompleted: isBudgetCompleted,
        ),
      _ => throw const FormatException('Failed to parse AuthResponseModel.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'isNew': isNew,
      'isBudgetCompleted': isBudgetCompleted,
    };
  }
}
