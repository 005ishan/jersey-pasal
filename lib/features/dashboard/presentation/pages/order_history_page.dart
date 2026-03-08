import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jerseypasal/core/constants/hive_table_constant.dart';
import 'package:jerseypasal/features/auth/domain/entities/order_entity.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_order_history_usecase.dart';
import 'package:jerseypasal/features/dashboard/data/datasources/local/order_local_datasource.dart';
import 'package:jerseypasal/features/dashboard/data/datasources/remote/order_remote_datasource.dart';
import 'package:jerseypasal/features/dashboard/data/models/order_model.dart';
import 'package:jerseypasal/features/dashboard/data/repositories/order_repository_impl.dart';

// ─── Events ────────────────────────────────────────────────────────────────
abstract class OrderHistoryEvent {}

class FetchOrderHistory extends OrderHistoryEvent {
  final String userId;
  FetchOrderHistory(this.userId);
}

// ─── States ────────────────────────────────────────────────────────────────
abstract class OrderHistoryState {}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderEntity> orders;
  OrderHistoryLoaded(this.orders);
}

class OrderHistoryError extends OrderHistoryState {
  final String message;
  OrderHistoryError(this.message);
}

// ─── BLoC ──────────────────────────────────────────────────────────────────
class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  final GetOrderHistoryUsecase getOrderHistory;

  OrderHistoryBloc(this.getOrderHistory) : super(OrderHistoryInitial()) {
    on<FetchOrderHistory>((event, emit) async {
      emit(OrderHistoryLoading());
      try {
        final orders = await getOrderHistory(event.userId);
        emit(OrderHistoryLoaded(orders));
      } catch (e) {
        emit(OrderHistoryError(e.toString()));
      }
    });
  }
}

// ─── Page ──────────────────────────────────────────────────────────────────
class OrderHistoryPage extends StatelessWidget {
  final String userId;
  const OrderHistoryPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📋 OrderHistoryPage userId: $userId');
    return BlocProvider(
      create: (_) => OrderHistoryBloc(
        GetOrderHistoryUsecase(
          OrderRepositoryImpl(
            remote: OrderRemoteDatasourceImpl(http.Client()),
            local: OrderLocalDatasourceImpl(
              Hive.box<OrderModel>(HiveTableConstant.orderTable),
            ),
          ),
        ),
      )..add(FetchOrderHistory(userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Purchase History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey.shade200, height: 1),
          ),
        ),
        body: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
          builder: (context, state) {
            if (state is OrderHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1877F2)),
              );
            }

            if (state is OrderHistoryError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is OrderHistoryLoaded) {
              final orders = state.orders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 72,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No purchases yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your completed orders will appear here',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return _OrderCard(order: order);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─── Order Card Widget ─────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId.length >= 8 ? order.orderId.substring(0, 8).toUpperCase() : order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.paymentMethod,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ─── Date ────────────────────────────────────────────
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.purchasedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),

            const Divider(height: 20),

            // ─── Items ───────────────────────────────────────────
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} × ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rs${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 16),

            // ─── Total ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} item(s)',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                Text(
                  'Rs${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
