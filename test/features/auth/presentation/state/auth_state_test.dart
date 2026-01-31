import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';

void main() {
  /// unit test no 1
  test('AuthState default values are correct', () {
    final state = AuthState();

    expect(state.status, AuthStatus.initial);
    expect(state.authEntity, null);
    expect(state.errorMessage, null);
  });

  /// unit test no 2
  test('copyWith updates status correctly', () {
    final state = AuthState();

    final newState = state.copyWith(status: AuthStatus.loading);

    expect(newState.status, AuthStatus.loading);
    expect(newState.authEntity, null);
    expect(newState.errorMessage, null);
  });

  /// unit test no 3
  test('copyWith updates errorMessage correctly', () {
    final state = AuthState();

    final newState = state.copyWith(errorMessage: 'Invalid credentials');

    expect(newState.status, AuthStatus.initial);
    expect(newState.errorMessage, 'Invalid credentials');
  });

  /// unit test no 4
  test('copyWith updates authEntity correctly', () {
    final authEntity = AuthEntity(authId: '1', email: 'test@example.com');

    final state = AuthState();

    final newState = state.copyWith(authEntity: authEntity);

    expect(newState.authEntity, authEntity);
    expect(newState.status, AuthStatus.initial);
  });

  /// unit test no 5
  test('Two AuthState objects with same values are equal', () {
    final state1 = AuthState(
      status: AuthStatus.authenticated,
      errorMessage: null,
    );

    final state2 = AuthState(
      status: AuthStatus.authenticated,
      errorMessage: null,
    );

    expect(state1, equals(state2));
  });
}
