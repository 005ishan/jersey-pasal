import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jerseypasal/features/dashboard/data/models/cartitem_model.dart';
import 'package:jerseypasal/features/dashboard/data/datasources/api_service.dart';

// Cart StateNotifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  int get totalItems =>
      state.fold(0, (previous, element) => previous + element.quantity);

  Future<void> fetchCart(String token) async {
    final items = await ApiService.getCart(token);
    state = items;
  }

  Future<void> addItem(String token, String productId, int qty) async {
    await ApiService.addToCart(token, productId, qty);
    await fetchCart(token);
  }

  Future<void> removeItem(String token, String productId) async {
    await ApiService.removeFromCart(token, productId);
    await fetchCart(token);
  }
}

// Riverpod provider
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());