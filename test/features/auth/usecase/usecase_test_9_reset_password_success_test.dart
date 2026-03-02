import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const tEmail = 'test@example.com';

void main() {
  test('9. ResetPasswordUsecase returns true on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.resetPassword(email: tEmail, newPassword: 'newPass123'))
        .thenAnswer((_) async => const Right(true));

    final usecase = ResetPasswordUsecase(authRepository: mockRepo);
    final result = await usecase(
        ResetPasswordUsecaseParams(email: tEmail, newPassword: 'newPass123'));

    expect(result, const Right(true));
    verify(() => mockRepo.resetPassword(email: tEmail, newPassword: 'newPass123'))
        .called(1);
  });
}
