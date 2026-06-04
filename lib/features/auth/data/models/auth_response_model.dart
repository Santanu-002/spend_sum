import 'package:spend_sum/features/auth/domain/entities/auth_response.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.uid,
    required super.isNew,
    required super.isBudgetCompleted,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      uid: json['uid'] as String,
      isNew: json['isNew'] as bool,
      isBudgetCompleted: json['isBudgetCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'isNew': isNew,
      'isBudgetCompleted': isBudgetCompleted,
    };
  }
}
