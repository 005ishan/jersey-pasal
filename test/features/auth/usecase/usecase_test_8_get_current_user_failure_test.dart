import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  test('8. GetCurrentUserUsecase returns Failure when not logged in', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.getCurrentUser())
        .thenAnswer((_) async => Left(ApiFailure(message: 'Not authenticated')));

    final usecase = GetCurrentUserUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f.message, 'Not authenticated'),
      (_) => fail('Expected failure'),
    );
  });
}
