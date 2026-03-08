import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tAuthEntity = AuthEntity(email: tEmail);

/// Runs [action] inside a real widget tree so ScaffoldMessenger.of(context) works.
Future<void> runWithContext(
  WidgetTester tester,
  ProviderContainer container,
  Future<void> Function(BuildContext ctx) action,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (ctx) {
            // kick off action after first frame
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await action(ctx);
            });
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late MockLoginUsecase mockLogin;
  late MockRegisterUsecase mockRegister;
  late MockLogoutUsecase mockLogout;
  late MockGetCurrentUserUsecase mockGetCurrentUser;
  late MockResetPasswordUsecase mockResetPassword;

  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  setUp(() {
    mockLogin = MockLoginUsecase();
    mockRegister = MockRegisterUsecase();
    mockLogout = MockLogoutUsecase();
    mockGetCurrentUser = MockGetCurrentUserUsecase();
    mockResetPassword = MockResetPasswordUsecase();
  });

  test('1. initial state is initial with no user and no error', () {

    final container = ProviderContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(mockLogin),
      registerUsecaseProvider.overrideWithValue(mockRegister),
      logoutUsecaseProvider.overrideWithValue(mockLogout),
      getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrentUser),
      resetPasswordUsecaseProvider.overrideWithValue(mockResetPassword),
    ]);
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.initial);
    expect(state.authEntity, isNull);
    expect(state.errorMessage, isNull);
  });
}