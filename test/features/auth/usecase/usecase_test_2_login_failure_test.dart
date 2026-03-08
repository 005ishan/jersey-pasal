import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const tEmail = 'test@example.com';
const tPassword = 'password123';

void main() {
  test('2. LoginUsecase returns Failure on wrong credentials', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => Left(ApiFailure(message: 'Invalid credentials')));

    final usecase = LoginUsecase(authRepository: mockRepo);
    final result = await usecase(LoginUsecaseParams(email: tEmail, password: tPassword));

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f.message, 'Invalid credentials'),
      (_) => fail('Expected failure'),
    );
  });
}
