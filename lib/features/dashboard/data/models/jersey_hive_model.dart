import 'package:hive/hive.dart';
part 'jersey_hive_model.g.dart';

@HiveType(typeId: 7)
class JerseyHiveModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final double price;
  @HiveField(3) final String? imageUrl;
  @HiveField(4) final String? itemType; // 'club' or 'country'

  JerseyHiveModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.itemType,
  });

  factory JerseyHiveModel.fromJson(Map<String, dynamic> json) => JerseyHiveModel(
    id: json['_id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl']?.toString(),
    itemType: json['itemType']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'itemType': itemType,
  };
}