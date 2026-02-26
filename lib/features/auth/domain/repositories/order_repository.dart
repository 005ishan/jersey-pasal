import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrderHistory(String userId);
  Future<void> saveOrder(OrderEntity order);
}