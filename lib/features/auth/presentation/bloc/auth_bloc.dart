import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/features/auth/domain/usecases/register_user.dart';
import 'package:spend_sum/features/auth/domain/usecases/send_otp.dart';
import 'package:spend_sum/features/auth/domain/usecases/submit_budget_details.dart';
import 'package:spend_sum/features/auth/domain/usecases/verify_otp.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_event.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_state.dart';

/// Business Logic Component managing user login, OTP validation, profile registration, and budget surveys.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final RegisterUser registerUser;
  final SubmitBudgetDetails submitBudgetDetails;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.registerUser,
    required this.submitBudgetDetails,
  }) : super(const AuthInitial()) {
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSubmitBudgetRequested>(_onSubmitBudgetRequested);
    on<AuthResetRequested>(_onResetRequested);
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isResend = state is AuthOtpSent;
    emit(AuthLoading(isResending: isResend));
    final result = await sendOtp(event.formattedPhone);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpSent(event.formattedPhone)),
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await verifyOtp(
      VerifyOtpParams(
        phoneNumber: event.phoneNumber,
        verificationCode: event.verificationCode,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (response) => emit(
        AuthSuccess(
          uid: response.uid,
          isNew: response.isNew,
          isBudgetCompleted: response.isBudgetCompleted,
        ),
      ),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUser(
      RegisterUserParams(
        uid: event.uid,
        name: event.name,
        dob: event.dob,
        gender: event.gender,
        email: event.email,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(
        AuthSuccess(uid: event.uid, isNew: false, isBudgetCompleted: false),
      ),
    );
  }

  Future<void> _onSubmitBudgetRequested(
    AuthSubmitBudgetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await submitBudgetDetails(
      SubmitBudgetParams(
        uid: event.uid,
        amount: event.amount,
        period: event.period,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(
        AuthSuccess(uid: event.uid, isNew: false, isBudgetCompleted: true),
      ),
    );
  }

  void _onResetRequested(AuthResetRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
