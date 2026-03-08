import 'package:hive/hive.dart';
part 'wishlist_hive_model.g.dart';

@HiveType(typeId: 8)
class WishlistHiveModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final double price;
  @HiveField(3) final String? imageUrl;

  WishlistHiveModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory WishlistHiveModel.fromJson(Map<String, dynamic> json) => WishlistHiveModel(
    id: json['_id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
  };
}