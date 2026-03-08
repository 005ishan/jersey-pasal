import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  test('3. RegisterUsecase returns true on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.register(any())).thenAnswer((_) async => const Right(true));

    final usecase = RegisterUsecase(authRepository: mockRepo);
    final result = await usecase(RegisterUsecaseParams(email: tEmail, password: tPassword));

    expect(result, const Right(true));
    verify(() => mockRepo.register(any())).called(1);
  });
}
