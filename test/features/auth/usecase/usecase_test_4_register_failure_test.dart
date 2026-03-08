import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const tEmail = 'test@example.com';
const tPassword = 'password123';

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthEntity(email: ''));
  });

  test('4. RegisterUsecase returns Failure when email already exists', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.register(any()))
        .thenAnswer((_) async => Left(ApiFailure(message: 'Email already exists')));

    final usecase = RegisterUsecase(authRepository: mockRepo);
    final result = await usecase(RegisterUsecaseParams(email: tEmail, password: tPassword));

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f.message, 'Email already exists'),
      (_) => fail('Expected failure'),
    );
  });
}
