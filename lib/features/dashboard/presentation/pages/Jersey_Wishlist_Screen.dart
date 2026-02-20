import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/features/dashboard/presentation/providers/wishlist_provider.dart';

class JerseyWishlistScreen extends ConsumerWidget {
  const JerseyWishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistItems = ref.watch(wishlistProvider);
    final wishlistNotifier = ref.read(wishlistProvider.notifier);

    return Scaffold(
      appBar: const JerseyAppBar(), // remove title if your AppBar doesn't take it
      body: wishlistItems.isEmpty
          ? const Center(child: Text('Your wishlist is empty'))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: item.product.imageUrl != null
                        ? Image.network(item.product.imageUrl!)
                        : const Icon(Icons.image),
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await wishlistNotifier.removeItem(
                            'your_token_here', item.product.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}