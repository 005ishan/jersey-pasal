import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tAuthEntity = AuthEntity(email: tEmail);

void main() {
  test('1. LoginUsecase returns AuthEntity on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tAuthEntity));

    final usecase = LoginUsecase(authRepository: mockRepo);
    final result = await usecase(LoginUsecaseParams(email: tEmail, password: tPassword));

    expect(result, const Right(tAuthEntity));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
  });
}
