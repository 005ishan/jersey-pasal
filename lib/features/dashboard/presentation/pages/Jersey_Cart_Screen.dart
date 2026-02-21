import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';

class JerseyCartScreen extends StatefulWidget {
  const JerseyCartScreen({Key? key}) : super(key: key);

  @override
  State<JerseyCartScreen> createState() => _JerseyCartScreenState();
}

class _JerseyCartScreenState extends State<JerseyCartScreen> {
  void showStyledSnackBar(String message, {bool isError = false}) {
    final color = isError ? Colors.redAccent : Colors.green;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),

        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> cartItems = [];
  bool loading = false;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
    ),
  );

  final String userId = "696858e56184236c74bbf2b9";

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  /// ================= FETCH CART =================
  Future<void> fetchCart() async {
    try {
      setState(() => loading = true);

      final response = await dio.get("${ApiEndpoints.cart}?userId=$userId");

      final items = response.data?['cart']?['items'] as List<dynamic>? ?? [];

      setState(() {
        cartItems = items;
      });
    } catch (e) {
      debugPrint("Cart Fetch Error: $e");
      setState(() => cartItems = []);
    } finally {
      setState(() => loading = false);
    }
  }

  /// ================= REMOVE FROM CART =================
  Future<void> removeFromCart(String productId) async {
    try {
      await dio.post(
        ApiEndpoints.removeFromCart,
        data: {"userId": userId, "productId": productId},
      );

      showStyledSnackBar("Removed from cart");

      fetchCart();
    } catch (e) {
      debugPrint("Remove Cart Error: $e");
    }
  }

  /// ================= TOTAL PRICE =================
  double get totalPrice {
    double total = 0;

    for (var item in cartItems) {
      final product = item?['product'];
      final quantity = (item?['quantity'] ?? 0) as num;

      if (product is Map && product['price'] != null) {
        total += (product['price'] as num).toDouble() * quantity;
      }
    }

    return total;
  }

  void checkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checkout not implemented yet")),
    );
  }

  /// ================= IMAGE URL BUILDER =================
  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "http://192.168.137.1:3000/uploads/default.png";
    }

    if (path.startsWith("http")) {
      return path;
    }

    return "http://192.168.137.1:3000$path";
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const JerseyAppBar(),

      body: Column(
        children: [
          /// ⭐ Loading Indicator (Only inside header area)
          if (loading) const LinearProgressIndicator(minHeight: 2),

          /// ================= CART CONTENT =================
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Cart is empty"))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];

                      final product = cartItem?['product'];
                      final quantity = cartItem?['quantity'] ?? 1;

                      if (product is! Map) return const SizedBox();

                      final imageUrl = _buildImageUrl(
                        product['imageUrl']?.toString(),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(
                            product['name'] ?? "Unknown Product",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "\$${product['price'] ?? 0} x $quantity",
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              final productId = cartItem['product']?['_id'];
                              if (productId != null) {
                                removeFromCart(productId.toString());
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          /// ================= TOTAL + CHECKOUT =================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// Checkout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
