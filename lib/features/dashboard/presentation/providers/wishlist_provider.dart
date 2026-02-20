import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jerseypasal/features/dashboard/data/models/cartitem_model.dart'; // reuse model if wishlist items are similar
import 'package:jerseypasal/features/dashboard/data/datasources/api_service.dart';

// Wishlist StateNotifier
class WishlistNotifier extends StateNotifier<List<CartItem>> {
  WishlistNotifier() : super([]);

  int get totalItems =>
      state.fold(0, (previous, element) => previous + element.quantity);

  Future<void> fetchWishlist(String token) async {
    final items = await ApiService.getWishlist(token);
    state = items.cast<CartItem>();
  }

  Future<void> addItem(String token, String productId) async {
    await ApiService.addToWishlist(token, productId);
    await fetchWishlist(token);
  }

  Future<void> removeItem(String token, String productId) async {
    await ApiService.removeFromWishlist(token, productId);
    await fetchWishlist(token);
  }
}

// Riverpod provider
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<CartItem>>(
      (ref) => WishlistNotifier(),
    );
