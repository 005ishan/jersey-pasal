import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  test('5. LogoutUsecase returns true on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.logout()).thenAnswer((_) async => const Right(true));

    final usecase = LogoutUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result, const Right(true));
    verify(() => mockRepo.logout()).called(1);
  });
}
