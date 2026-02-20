import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/features/dashboard/data/models/cartitem_model.dart';
import 'package:jerseypasal/features/dashboard/presentation/providers/cart_provider.dart';

class JerseyCartScreen extends ConsumerWidget {
  const JerseyCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: JerseyAppBar(),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: item.product.imageUrl != null
                        ? Image.network(item.product.imageUrl!)
                        : const Icon(Icons.image),
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () async {
                            if (item.quantity > 1) {
                              await cartNotifier.addItem(
                                'your_token_here',
                                item.product.id,
                                -1,
                              );
                            } else {
                              await cartNotifier.removeItem(
                                'your_token_here',
                                item.product.id,
                              );
                            }
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            await cartNotifier.addItem(
                              'your_token_here',
                              item.product.id,
                              1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
