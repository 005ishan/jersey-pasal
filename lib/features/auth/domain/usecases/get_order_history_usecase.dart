import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/order_repository.dart';

class GetOrderHistoryUsecase {
  final OrderRepository repository;

  GetOrderHistoryUsecase(this.repository);

  Future<List<OrderEntity>> call(String userId) {
    return repository.getOrderHistory(userId);
  }
}