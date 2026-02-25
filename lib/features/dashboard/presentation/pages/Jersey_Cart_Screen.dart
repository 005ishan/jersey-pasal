import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/esewa_gateway_screen.dart';
import 'package:shimmer/shimmer.dart';

class JerseyCartScreen extends StatefulWidget {
  const JerseyCartScreen({Key? key}) : super(key: key);

  @override
  State<JerseyCartScreen> createState() => _JerseyCartScreenState();
}

class _JerseyCartScreenState extends State<JerseyCartScreen> {
  // ─── Snackbar ───────────────────────────────────────────────────────────────
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

  // ─── State ──────────────────────────────────────────────────────────────────
  List<dynamic> cartItems = [];
  bool loading = false;
  final Set<String> _updatingItems = {};

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

  // ─── FETCH CART ─────────────────────────────────────────────────────────────
  Future<void> fetchCart() async {
    try {
      setState(() => loading = true);
      final response = await dio.get("${ApiEndpoints.cart}?userId=$userId");
      final items = response.data?['cart']?['items'] as List<dynamic>? ?? [];
      setState(() => cartItems = items);
    } catch (e) {
      debugPrint("Cart Fetch Error: $e");
      setState(() => cartItems = []);
    } finally {
      setState(() => loading = false);
    }
  }

  // ─── UPDATE QUANTITY ────────────────────────────────────────────────────────
  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (_updatingItems.contains(productId)) return;
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    try {
      setState(() => _updatingItems.add(productId));
      setState(() {
        for (var item in cartItems) {
          if (item['product']?['_id']?.toString() == productId) {
            item['quantity'] = newQuantity;
            break;
          }
        }
      });
      await dio.post(
        ApiEndpoints.addToCart,
        data: {
          "userId": userId,
          "productId": productId,
          "quantity": newQuantity,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (e) {
      debugPrint("Update quantity error: $e");
      showStyledSnackBar("Failed to update quantity", isError: true);
      fetchCart();
    } finally {
      setState(() => _updatingItems.remove(productId));
    }
  }

  // ─── REMOVE SINGLE ITEM ─────────────────────────────────────────────────────
  Future<void> removeFromCart(String productId) async {
    try {
      setState(() => _updatingItems.add(productId));
      await dio.post(
        ApiEndpoints.removeFromCart,
        data: {"userId": userId, "productId": productId},
      );
      showStyledSnackBar("Item removed from cart");
      fetchCart();
    } catch (e) {
      debugPrint("Remove Cart Error: $e");
      showStyledSnackBar("Failed to remove item", isError: true);
    } finally {
      setState(() => _updatingItems.remove(productId));
    }
  }

  // ─── CLEAR ENTIRE CART ──────────────────────────────────────────────────────
  Future<void> clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Clear Cart?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "All items will be removed from your cart. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Clear All",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => loading = true);
      for (var item in List.from(cartItems)) {
        final productId = item['product']?['_id']?.toString();
        if (productId != null) {
          await dio.post(
            ApiEndpoints.removeFromCart,
            data: {"userId": userId, "productId": productId},
          );
        }
      }
      setState(() => cartItems = []);
      showStyledSnackBar("Cart cleared successfully");
    } catch (e) {
      debugPrint("Clear cart error: $e");
      showStyledSnackBar("Failed to clear cart", isError: true);
      fetchCart();
    } finally {
      setState(() => loading = false);
    }
  }

  // ─── TOTALS ─────────────────────────────────────────────────────────────────
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

  int get totalItems {
    int count = 0;
    for (var item in cartItems) {
      count += ((item?['quantity'] ?? 0) as num).toInt();
    }
    return count;
  }

  // ─── CHECKOUT ───────────────────────────────────────────────────────────────
  void checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EsewaGatewayScreen(amount: totalPrice)),
    );
  }

  // ─── IMAGE URL ──────────────────────────────────────────────────────────────
  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "http://192.168.137.1:3000/uploads/default.png";
    }
    if (path.startsWith("http")) return path;
    return "http://192.168.137.1:3000$path";
  }

  // ─── QUANTITY CONTROL ───────────────────────────────────────────────────────
  Widget _buildQuantityControl(String productId, int quantity) {
    final isUpdating = _updatingItems.contains(productId);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _circleIconBtn(
          icon: Icons.remove,
          color: Colors.blueAccent,
          onPressed: isUpdating || quantity <= 1
              ? null
              : () => updateQuantity(productId, quantity - 1),
        ),
        SizedBox(
          width: 36,
          child: isUpdating
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        _circleIconBtn(
          icon: Icons.add,
          color: Colors.blueAccent,
          onPressed: isUpdating
              ? null
              : () => updateQuantity(productId, quantity + 1),
        ),
      ],
    );
  }

  Widget _circleIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed == null
            ? Colors.grey.shade200
            : color.withOpacity(0.12),
        border: Border.all(
          color: onPressed == null
              ? Colors.grey.shade300
              : color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: onPressed == null ? Colors.grey : color,
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ─── SHIMMER LIST ───────────────────────────────────────────────────────────
  Widget buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 80, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(height: 28, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: loading ? null : clearCart,
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.redAccent,
                  size: 20,
                ),
                label: const Text(
                  "Clear Cart",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          if (loading) const LinearProgressIndicator(minHeight: 2),

          // ─── Cart List ──────────────────────────────────────────────────
          Expanded(
            child: loading
                ? buildShimmerList() // ⭐ shimmer while loading
                : cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Your cart is empty",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Add some jerseys to get started!",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final product = cartItem?['product'];
                      final quantity = ((cartItem?['quantity'] ?? 1) as num)
                          .toInt();

                      if (product is! Map) return const SizedBox();

                      final productId = product['_id']?.toString() ?? '';
                      final price =
                          (product['price'] as num?)?.toDouble() ?? 0.0;
                      final imageUrl = _buildImageUrl(
                        product['imageUrl']?.toString(),
                      );
                      final isUpdating = _updatingItems.contains(productId);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// ⭐ CachedNetworkImage with shimmer placeholder
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.white,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product['name'] ??
                                                "Unknown Product",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 6),

                                        GestureDetector(
                                          onTap: isUpdating
                                              ? null
                                              : () => removeFromCart(productId),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isUpdating
                                                  ? Colors.grey.shade100
                                                  : Colors.red.shade50,
                                            ),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 17,
                                              color: isUpdating
                                                  ? Colors.grey.shade400
                                                  : Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      "Rs${price.toStringAsFixed(2)} each",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildQuantityControl(
                                          productId,
                                          quantity,
                                        ),
                                        Text(
                                          "Rs${(price * quantity).toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ─── Footer ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$totalItems item(s)",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Total: ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Rs${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF60BB46),
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: cartItems.isEmpty
                        ? const Text(
                            "Proceed to Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Esewa Pay Now",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
