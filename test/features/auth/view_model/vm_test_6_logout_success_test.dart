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

/// Runs [action] with a real BuildContext so ScaffoldMessenger works.
/// Uses pump() instead of pumpAndSettle() to capture state BEFORE
/// the ViewModel navigates away (which would try to open Hive boxes).
Future<void> runWithContext(
  WidgetTester tester,
  ProviderContainer container,
  Future<void> Function(BuildContext ctx) action,
) async {
  late BuildContext capturedCtx;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(builder: (ctx) {
          capturedCtx = ctx;
          return const Scaffold(body: SizedBox());
        }),
      ),
    ),
  );

  // Run the action with the captured context
  await action(capturedCtx);

  // Single pump — captures state update but does NOT follow navigation
  await tester.pump();
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

  testWidgets('6. logout success sets status to unauthenticated', (tester) async {
    when(() => mockLogout.call()).thenAnswer((_) async => const Right(true));
    final container = ProviderContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(mockLogin),
      registerUsecaseProvider.overrideWithValue(mockRegister),
      logoutUsecaseProvider.overrideWithValue(mockLogout),
      getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrentUser),
      resetPasswordUsecaseProvider.overrideWithValue(mockResetPassword),
    ]);
    await runWithContext(tester, container, (ctx) =>
      container.read(authViewModelProvider.notifier).logout(context: ctx),
    );
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.authEntity, isNull);
  });
}