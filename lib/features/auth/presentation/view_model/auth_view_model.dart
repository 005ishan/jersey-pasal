import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/routes/app_routes.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/Jersey_Home_Screen.dart';

// Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);

    return const AuthState();
  }

  Future<void> register({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RegisterUsecaseParams(
      email: email,
      password: password,
    );

    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        SnackbarUtils.showError(context, failure.message);
      },
      (success) {
        state = state.copyWith(
          status: success ? AuthStatus.authenticated : AuthStatus.error,
        );

        if (success) {
          SnackbarUtils.showSuccess(context, "Registration successful!");

          // Navigate to Login screen after registration
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRoutes.pushReplacement(context, const JerseyLoginScreen());
          });
        } else {
          SnackbarUtils.showError(context, "Registration failed");
        }
      },
    );
  }

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase.call(params);

    result.fold(
      (failure) {
        // Login failed
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );

        // Show error snackbar
        SnackbarUtils.showError(context, failure.message);
      },
      (user) {
        // Login successful
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: user,
        );

        // Show success snackbar
        SnackbarUtils.showSuccess(context, "Login successful!");

        // Navigate safely after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRoutes.pushReplacement(
            context,
            const JerseyHomeScreen(), // <-- Your home screen
          );
        });
      },
    );
  }

  Future<void> logout({required BuildContext context}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _logoutUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        SnackbarUtils.showError(context, failure.message);
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          authEntity: null,
        );
        SnackbarUtils.showSuccess(context, "Logged out successfully!");
      },
    );
  }

  Future<void> getCurrentUser({required BuildContext context}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _getCurrentUserUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        SnackbarUtils.showError(context, failure.message);
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: user,
        );
      },
    );
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = ResetPasswordUsecaseParams(
      email: email,
      newPassword: newPassword,
    );

    final result = await _resetPasswordUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        SnackbarUtils.showError(context, failure.message);
      },
      (success) {
        state = state.copyWith(
          status: success ? AuthStatus.unauthenticated : AuthStatus.error,
          errorMessage: success ? null : "Password reset failed",
        );
        if (success) {
          SnackbarUtils.showSuccess(context, "Password reset successful!");
        } else {
          SnackbarUtils.showError(context, "Password reset failed");
        }
      },
    );
  }
}
