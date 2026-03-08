import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const tEmail = 'test@example.com';
const tAuthEntity = AuthEntity(email: tEmail);

void main() {
  test('7. GetCurrentUserUsecase returns AuthEntity on success', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.getCurrentUser())
        .thenAnswer((_) async => const Right(tAuthEntity));

    final usecase = GetCurrentUserUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result, const Right(tAuthEntity));
    verify(() => mockRepo.getCurrentUser()).called(1);
  });
}
