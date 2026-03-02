import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_item_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/order_repository.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_order_history_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  test('10. GetOrderHistoryUsecase returns list of orders for userId', () async {
    final mockRepo = MockOrderRepository();

    final tOrder = OrderEntity(
      orderId: 'o1',
      purchasedAt: DateTime(2024, 1, 1),
      items: [
        OrderItemEntity(
          productId: 'p1',
          productName: 'Jersey',
          quantity: 2,
          price: 500.0,
        ),
      ],
      totalAmount: 1000.0,
      paymentMethod: 'eSewa',
      userId: 'u1',
    );

    when(() => mockRepo.getOrderHistory('u1'))
        .thenAnswer((_) async => [tOrder]);

    final usecase = GetOrderHistoryUsecase(mockRepo);
    final result = await usecase('u1');

    expect(result.length, 1);
    expect(result.first.orderId, 'o1');
    expect(result.first.totalAmount, 1000.0);
    verify(() => mockRepo.getOrderHistory('u1')).called(1);
  });
}
