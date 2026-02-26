import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jerseypasal/core/api/api_endpoints.dart';
import 'package:jerseypasal/features/dashboard/data/models/order_model.dart';

abstract class OrderRemoteDatasource {
  Future<List<OrderModel>> getOrderHistory(String userId);
  Future<OrderModel> saveOrder(OrderModel order);
}

class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final http.Client client;

  OrderRemoteDatasourceImpl(this.client);

  @override
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.ordersBaseUrl}/orders/$userId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch order history');
  }

  @override
  Future<OrderModel> saveOrder(OrderModel order) async {
    final response = await client.post(
      Uri.parse('${ApiEndpoints.ordersBaseUrl}/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return OrderModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to save order');
  }
}