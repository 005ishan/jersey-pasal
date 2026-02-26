import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/order_repository.dart';

class SaveOrderUsecase {
  final OrderRepository repository;

  SaveOrderUsecase(this.repository);

  Future<void> call(OrderEntity order) {
    return repository.saveOrder(order);
  }
}