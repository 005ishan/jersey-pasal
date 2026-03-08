import 'package:hive/hive.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_item_entity.dart';

part 'order_item_model.g.dart';

@HiveType(typeId: 1)
class OrderItemModel extends HiveObject {
  @HiveField(0) final String productId;
  @HiveField(1) final String productName;
  @HiveField(2) final int quantity;
  @HiveField(3) final double price;
  @HiveField(4) final String? imageUrl;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'imageUrl': imageUrl,
  };

  OrderItemEntity toEntity() => OrderItemEntity(
    productId: productId,
    productName: productName,
    quantity: quantity,
    price: price,
    imageUrl: imageUrl,
  );

  factory OrderItemModel.fromEntity(OrderItemEntity e) => OrderItemModel(
    productId: e.productId,
    productName: e.productName,
    quantity: e.quantity,
    price: e.price,
    imageUrl: e.imageUrl,
  );
}