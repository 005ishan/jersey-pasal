import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';


class JerseyWishlistScreen extends StatefulWidget {
  const JerseyWishlistScreen({Key? key}) : super(key: key);

  @override
  _JerseyWishlistScreenState createState() => _JerseyWishlistScreenState();
}

class _JerseyWishlistScreenState extends State<JerseyWishlistScreen> {
  List<dynamic> wishlistItems = [];
  bool loading = true;

  final String testUserId = "696858e56184236c74bbf2b9";

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  /// Image Builder (Same as HomeScreen)
  String buildImageUrl(String? path) {
    if (path != null && path.startsWith("http")) {
      return path;
    }
    return "http://192.168.137.1:3000${path ?? "/uploads/default.png"}";
  }

  /// Fetch Wishlist
  void fetchWishlist() async {
    setState(() => loading = true);

    try {
      final res = await dio.get(
        ApiEndpoints.wishlist,
        queryParameters: {"userId": testUserId},
      );

      setState(() {
        wishlistItems = res.data['wishlist']?['products'] ?? [];
      });
    } catch (e) {
      debugPrint("Wishlist fetch error: $e");
    }

    setState(() => loading = false);
  }

  /// Toggle Wishlist
  void toggleWishlist(String productId) async {
    try {
      await dio.post(
        ApiEndpoints.toggleWishlist,
        data: {"userId": testUserId, "productId": productId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      SnackbarUtils.showSuccess(context, "Wishlist Updated");

      fetchWishlist();
    } catch (e) {
      debugPrint("Wishlist toggle error: $e");
    }
  }

  /// Wishlist Card UI
  Widget buildWishlistCard(dynamic item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          /// Image
          Positioned.fill(
            child: Image.network(
              buildImageUrl(item['imageUrl']),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50),
            ),
          ),

          /// Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ),

          /// Product Info
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  "\$${item['price'] ?? 0}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// Remove Favourite Button
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.favorite, color: Colors.red, size: 18),
                onPressed: () => toggleWishlist(item['_id']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const JerseyAppBar(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Heading (Always Visible)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "My Wishlist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          /// Content Area
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : wishlistItems.isEmpty
                ? const Center(
                    child: Text(
                      "❤️ Your favourite list is empty",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: wishlistItems.length,
                    itemBuilder: (_, i) => buildWishlistCard(wishlistItems[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
