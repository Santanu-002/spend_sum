import 'package:spend_sum/core/error/app_exception.dart';

abstract interface class IAuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<void> verifyOtp(String phoneNumber, String verificationCode);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      // Simulate 2-second API server response delay
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw ServerException('Connection error: ${e.toString()}', details: e);
    }
  }

  @override
  Future<void> verifyOtp(String phoneNumber, String verificationCode) async {
    try {
      // Simulate 2-second verification latency
      await Future.delayed(const Duration(seconds: 2));

      // Simulate validation check
      if (verificationCode == '111111') {
        throw const ServerException('Invalid verification code entered.');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Verification failed: ${e.toString()}', details: e);
    }
  }
}
