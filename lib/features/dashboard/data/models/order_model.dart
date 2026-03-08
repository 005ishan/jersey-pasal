import 'package:hive/hive.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'order_item_model.dart';

part 'order_model.g.dart';

@HiveType(typeId: 0)
class OrderModel extends HiveObject {
  @HiveField(0) final String orderId;
  @HiveField(1) final DateTime purchasedAt;
  @HiveField(2) final List<OrderItemModel> items;
  @HiveField(3) final double totalAmount;
  @HiveField(4) final String paymentMethod;
  @HiveField(5) final String userId;

  OrderModel({
    required this.orderId,
    required this.purchasedAt,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.userId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    orderId: json['_id'],
    purchasedAt: DateTime.parse(json['purchasedAt']),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paymentMethod: json['paymentMethod'],
    userId: json['userId'] ?? '',
    items: (json['items'] as List)
        .map((e) => OrderItemModel.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,   
    'purchasedAt': purchasedAt.toIso8601String(),
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'items': items.map((e) => e.toJson()).toList(),
  };

  OrderEntity toEntity() => OrderEntity(
    orderId: orderId,
    purchasedAt: purchasedAt,
    totalAmount: totalAmount,
    paymentMethod: paymentMethod,
    userId: userId,
    items: items.map((e) => e.toEntity()).toList(),
  );

  factory OrderModel.fromEntity(OrderEntity e) => OrderModel(
    orderId: e.orderId,
    purchasedAt: e.purchasedAt,
    totalAmount: e.totalAmount,
    paymentMethod: e.paymentMethod,
    userId: e.userId,
    items: e.items.map((i) => OrderItemModel.fromEntity(i)).toList(),
  );
}