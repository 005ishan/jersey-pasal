import 'package:jerseypasal/features/auth/domain/entities/order_item_entity.dart';

class OrderEntity {
  final String orderId;
  final DateTime purchasedAt;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String paymentMethod;
  final String userId; 

  const OrderEntity({
    required this.orderId,
    required this.purchasedAt,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.userId, 
  });
}