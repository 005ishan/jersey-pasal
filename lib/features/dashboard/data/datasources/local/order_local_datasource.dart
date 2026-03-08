import 'package:hive/hive.dart';
import '../../models/order_model.dart';

abstract class OrderLocalDatasource {
  List<OrderModel> getCachedOrders();
  Future<void> cacheOrders(List<OrderModel> orders);
}

class OrderLocalDatasourceImpl implements OrderLocalDatasource {
  final Box<OrderModel> box;

  OrderLocalDatasourceImpl(this.box);

  @override
  List<OrderModel> getCachedOrders() {
    return box.values.toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  @override
  Future<void> cacheOrders(List<OrderModel> orders) async {
    await box.clear();
    final map = {for (var o in orders) o.orderId: o};
    await box.putAll(map);
  }
}