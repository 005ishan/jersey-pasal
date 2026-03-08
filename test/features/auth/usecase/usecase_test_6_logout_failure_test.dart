import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  test('6. LogoutUsecase returns Failure when logout fails', () async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.logout())
        .thenAnswer((_) async => Left(ApiFailure(message: 'Logout failed')));

    final usecase = LogoutUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f.message, 'Logout failed'),
      (_) => fail('Expected failure'),
    );
  });
}
