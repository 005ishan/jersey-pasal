import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/core/constants/hive_table_constant.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/core/utils/snackbar_utils.dart';
import 'package:jerseypasal/features/dashboard/data/models/jersey_hive_model.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shimmer/shimmer.dart';

class JerseyHomeScreen extends StatefulWidget {
  const JerseyHomeScreen({Key? key}) : super(key: key);

  @override
  _JerseyHomeScreenState createState() => _JerseyHomeScreenState();
}

class _JerseyHomeScreenState extends State<JerseyHomeScreen>
    with SingleTickerProviderStateMixin {
  // ─── State ──────────────────────────────────────────────────────────────────
  List<dynamic> items = [];
  bool loading = true;
  late TabController _tabController;
  late Box<JerseyHiveModel> _jerseyBox;

  final String testUserId = "696858e56184236c74bbf2b9";

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
    ),
  );

  // ─── Sensor State ───────────────────────────────────────────────────────────
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  DateTime? _lastShakeTime;
  DateTime? _lastTiltTime;

  // ─── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _jerseyBox = Hive.box<JerseyHiveModel>(HiveTableConstant.jerseyTable);
    _tabController = TabController(length: 2, vsync: this);
    fetchItems();
    _startShakeDetection();
    _startGyroscope();
  }

  // ─── Dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ─── SHAKE DETECTION (Accelerometer) ────────────────────────────────────────
  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > 20) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;
          _onShakeDetected();
        }
      }
    });
  }

  void _onShakeDetected() {
    debugPrint('📳 Shake detected! Refreshing jerseys...');
    SnackbarUtils.showSuccess(context, "🔄 Refreshing jerseys...");
    _shakeRefresh();
  }

  void _shakeRefresh() async {
    setState(() {
      items = [];
      loading = true;
    });

    try {
      final res = await dio.get(ApiEndpoints.jerseys);
      final freshItems = res.data['items'] as List? ?? [];

      await _jerseyBox.clear();
      for (var item in freshItems) {
        final model = JerseyHiveModel.fromJson(item);
        await _jerseyBox.put(model.id, model);
      }

      setState(() => items = freshItems);
    } catch (e) {
      debugPrint("Shake refresh error: $e");
      final cached = _jerseyBox.values.toList();
      setState(() => items = cached.map((e) => e.toJson()).toList());
      SnackbarUtils.showError(context, "Failed to refresh");
    } finally {
      setState(() => loading = false);
    }
  }

  // ─── GYROSCOPE (Tilt to Switch Tabs) ────────────────────────────────────────
  void _startGyroscope() {
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      final now = DateTime.now();
      // Debounce tilt — prevent rapid tab switching
      if (_lastTiltTime != null &&
          now.difference(_lastTiltTime!) < const Duration(milliseconds: 800)) {
        return;
      }

      if (event.y > 2.5) {
        // Tilting right → Country Jerseys (tab 1)
        if (_tabController.index != 1) {
          _lastTiltTime = now;
          _tabController.animateTo(1);
          debugPrint('📱 Tilted right → Country Jerseys');
        }
      } else if (event.y < -2.5) {
        // Tilting left → Club Jerseys (tab 0)
        if (_tabController.index != 0) {
          _lastTiltTime = now;
          _tabController.animateTo(0);
          debugPrint('📱 Tilted left → Club Jerseys');
        }
      }
    });
  }

  // ─── FETCH ITEMS ────────────────────────────────────────────────────────────
  void fetchItems() async {
    // Show cache instantly
    final cached = _jerseyBox.values.toList();
    if (cached.isNotEmpty) {
      setState(() {
        items = cached.map((e) => e.toJson()).toList();
        loading = false;
      });
    } else {
      setState(() => loading = true);
    }

    // Fetch fresh from backend
    try {
      final res = await dio.get(ApiEndpoints.jerseys);
      final freshItems = res.data['items'] as List? ?? [];

      await _jerseyBox.clear();
      for (var item in freshItems) {
        final model = JerseyHiveModel.fromJson(item);
        await _jerseyBox.put(model.id, model);
      }

      setState(() => items = freshItems);
    } catch (e) {
      debugPrint("Fetch error: $e");
      if (items.isEmpty) {
        SnackbarUtils.showError(context, "Failed to load jerseys");
      }
    } finally {
      setState(() => loading = false);
    }
  }

  // ─── FILTER ─────────────────────────────────────────────────────────────────
  List<dynamic> getClubItems() => items
      .where((e) => e['itemType']?.toString().toLowerCase() == 'club')
      .toList();

  List<dynamic> getCountryItems() => items
      .where((e) => e['itemType']?.toString().toLowerCase() == 'country')
      .toList();

  // ─── ADD TO CART ────────────────────────────────────────────────────────────
  void addToCart(String productId, int quantity) async {
    try {
      final res = await dio.post(
        ApiEndpoints.addToCart,
        data: {
          'userId': testUserId,
          'productId': productId,
          'quantity': quantity,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.data['success'] == true) {
        SnackbarUtils.showSuccess(context, "Added $quantity item(s) to Cart");
      } else {
        throw Exception(res.data['message']);
      }
    } catch (e) {
      SnackbarUtils.showError(context, "Failed to add to cart");
    }
  }

  // ─── WISHLIST ───────────────────────────────────────────────────────────────
  void toggleWishlist(String productId) async {
    try {
      final res = await dio.post(
        ApiEndpoints.toggleWishlist,
        data: {"userId": testUserId, "productId": productId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (res.data['success'] == true) {
        SnackbarUtils.showSuccess(context, "Wishlist Updated");
        setState(() {});
      }
    } catch (e) {
      debugPrint("Wishlist toggle error: $e");
    }
  }

  // ─── BOTTOM SHEET ───────────────────────────────────────────────────────────
  void showAddToCartSheet(dynamic item) {
    int quantity = 1;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    item['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rs${price.toStringAsFixed(2)} per item",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _qtyButton(
                            icon: Icons.remove,
                            onPressed: quantity > 1
                                ? () => setSheetState(() => quantity--)
                                : null,
                          ),
                          Container(
                            width: 48,
                            alignment: Alignment.center,
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _qtyButton(
                            icon: Icons.add,
                            onPressed: () => setSheetState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Rs${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        addToCart(item['_id'], quantity);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed == null
            ? Colors.grey.shade200
            : Colors.blueAccent.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: onPressed == null ? Colors.grey : Colors.blueAccent,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // ─── SHIMMER ────────────────────────────────────────────────────────────────
  Widget buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }

  // ─── PRODUCT CARD ────────────────────────────────────────────────────────────
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
          Expanded(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rs${item['price'] ?? '0'}",
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
                  onPressed: () => showAddToCartSheet(item),
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── GRID ───────────────────────────────────────────────────────────────────
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

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const JerseyAppBar(),
      body: Column(
        children: [
          // ─── Tab Bar ────────────────────────────────────────────
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

          // ─── Content ────────────────────────────────────────────
          Expanded(
            child: loading
                ? buildShimmerGrid()
                : TabBarView(
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
