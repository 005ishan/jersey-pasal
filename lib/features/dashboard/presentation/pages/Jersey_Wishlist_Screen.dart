import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/constants/hive_table_constant.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';
import 'package:jerseypasal/features/dashboard/data/models/wishlist_hive_model.dart';
import 'package:shimmer/shimmer.dart';

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
  final Box<WishlistHiveModel> _wishlistBox = Hive.box<WishlistHiveModel>(
    HiveTableConstant.wishlistTable,
  );

  void fetchWishlist() async {
    // ─── Show cache instantly ───
    final cached = _wishlistBox.values.toList();
    if (cached.isNotEmpty) {
      setState(() {
        wishlistItems = cached.map((e) => e.toJson()).toList();
        loading = false;
      });
    } else {
      setState(() => loading = true);
    }

    // ─── Fetch fresh from backend ───
    try {
      final res = await dio.get(
        ApiEndpoints.wishlist,
        queryParameters: {"userId": testUserId},
      );

      final freshItems = res.data['wishlist']?['products'] as List? ?? [];

      // Cache in Hive
      await _wishlistBox.clear();
      for (var item in freshItems) {
        final model = WishlistHiveModel.fromJson(item);
        await _wishlistBox.put(model.id, model);
      }

      setState(() => wishlistItems = freshItems);
    } catch (e) {
      debugPrint("Wishlist fetch error: $e");
      // Keep showing cached data
    } finally {
      setState(() => loading = false);
    }
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

  /// ---------------- SHIMMER GRID ----------------
  Widget buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  /// Wishlist Card UI
  Widget buildWishlistCard(dynamic item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          /// ⭐ CachedNetworkImage with shimmer placeholder
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: buildImageUrl(item['imageUrl']),
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image, size: 50)),
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
                  "\Rs${item['price'] ?? 0}",
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
                ? buildShimmerGrid() // ⭐ shimmer instead of CircularProgressIndicator
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
