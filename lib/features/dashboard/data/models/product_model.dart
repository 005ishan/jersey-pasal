class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["_id"],
      name: json["name"],
      category: json["category"],
      price: (json["price"] as num).toDouble(),
      imageUrl: json["imageUrl"] ?? "",
    );
  }
}