import 'package:dartz/dartz.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/order_repository.dart';
import 'package:jerseypasal/features/dashboard/data/datasources/local/order_local_datasource.dart';
import 'package:jerseypasal/features/dashboard/data/datasources/remote/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remote;
  final OrderLocalDatasource local;

  OrderRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<OrderEntity>> getOrderHistory(String userId) async {
    try {
      // Fetch from backend and sync into Hive
      final models = await remote.getOrderHistory(userId);
      await local.cacheOrders(models);
      return models.map((e) => e.toEntity()).toList();
    } catch (_) {
      // Fallback to Hive cache if network fails
      final cached = local.getCachedOrders();
      return cached.map((e) => e.toEntity()).toList();
    }
  }

  @override
  Future<void> saveOrder(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    final saved = await remote.saveOrder(model);
    await local.cacheOrders([...local.getCachedOrders(), saved]);
  }
}