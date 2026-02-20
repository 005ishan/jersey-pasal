import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/cartitem_model.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";

  // Wishlist
  static Future<List<Product>> getWishlist(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wishlist'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)["wishlist"]["products"] as List;
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch wishlist");
    }
  }

  static Future<void> toggleWishlist(String token, String productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wishlist/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to toggle wishlist");
    }
  }

  // Cart
  static Future<List<CartItem>> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final items = json.decode(response.body)["cart"]["items"] as List;
      return items.map((e) => CartItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch cart");
    }
  }

  static Future<void> addToCart(String token, String productId, int qty) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId, 'quantity': qty}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to add to cart");
    }
  }

  static Future<void> removeFromCart(String token, String productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/remove'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to remove from cart");
    }
  }

  static Future<void> addToWishlist(String token, String productId) async {}

  static Future<void> removeFromWishlist(String token, String productId) async {}
}