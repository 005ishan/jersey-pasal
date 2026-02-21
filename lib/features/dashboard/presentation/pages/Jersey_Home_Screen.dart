import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';

class JerseyHomeScreen extends StatefulWidget {
  const JerseyHomeScreen({Key? key}) : super(key: key);

  @override
  _JerseyHomeScreenState createState() => _JerseyHomeScreenState();
}

class _JerseyHomeScreenState extends State<JerseyHomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> items = [];
  bool loading = true;

  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
    fetchItems();
  }

  /// ---------------- FETCH ITEMS ----------------
  void fetchItems() async {
    try {
      setState(() => loading = true);

      final res = await dio.get(ApiEndpoints.jerseys);
      setState(() => items = res.data['items'] ?? []);
    } catch (e) {
      debugPrint("Fetch error: $e");
      SnackbarUtils.showError(context, "Failed to add to cart");
    } finally {
      setState(() => loading = false);
    }
  }

  /// ---------------- FILTER ITEMS ----------------
  List<dynamic> getClubItems() {
    return items
        .where((e) => e['itemType']?.toString().toLowerCase() == 'club')
        .toList();
  }

  List<dynamic> getCountryItems() {
    return items
        .where((e) => e['itemType']?.toString().toLowerCase() == 'country')
        .toList();
  }

  /// ---------------- CART ----------------
  void addToCart(String productId) async {
    try {
      final res = await dio.post(
        ApiEndpoints.addToCart,
        data: {'userId': testUserId, 'productId': productId, 'quantity': 1},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.data['success'] == true) {
        SnackbarUtils.showSuccess(context, "Added to Cart");
      } else {
        throw Exception(res.data['message']);
      }
    } catch (e) {
      SnackbarUtils.showError(context, "Failed to add to cart");
    }
  }

  /// ---------------- WISHLIST ----------------
  void toggleWishlist(String productId) async {
    try {
      final res = await dio.post(
        ApiEndpoints.toggleWishlist,
        data: {"userId": testUserId, "productId": productId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (res.data['success'] == true) {
        SnackbarUtils.showSuccess(context, "Wishlist Updated");

        /// ⭐ Refresh product list UI
        setState(() {});
      }
    } catch (e) {
      debugPrint("Wishlist toggle error: $e");
    }
  }

  /// ---------------- CARD WIDGET ----------------
  Widget buildProductCard(dynamic item) {
    final imageUrl =
        item['imageUrl'] != null && item['imageUrl'].startsWith('http')
        ? item['imageUrl']
        : 'http://192.168.137.1:3000${item['imageUrl'] ?? '/uploads/default.png'}';

    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Image Section
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),

                /// Wishlist Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      onPressed: () => toggleWishlist(item['_id']),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "\$${item['price'] ?? '0'}",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 38),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => addToCart(item['_id']),
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- GRID VIEW ----------------
  Widget buildGrid(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => buildProductCard(list[i]),
    );
  }

  /// ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const JerseyAppBar(),

      body: Column(
        children: [
          /// Gradient Tab Header
          /// Gradient Tab Header (Fix Visibility Issue)
          Material(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: "Club Jerseys"),
                    Tab(text: "Country Jerseys"),
                  ],
                ),
              ),
            ),
          ),

          /// Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildGrid(getClubItems()),
                buildGrid(getCountryItems()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
