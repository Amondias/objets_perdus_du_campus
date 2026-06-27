import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/items_provider.dart';
import '../items/item_detail_screen.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final pendingItems = itemsProvider.getPendingItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des annonces'),
      ),
      body: pendingItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: pendingItems.length,
              itemBuilder: (context, index) {
                final item = pendingItems[index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
                        leading: CircleAvatar(
                          backgroundColor: AppConfig.surfaceVariant,
                          child: Icon(AppConfig.getCategoryById(item.category)?['icon'] ?? Icons.category, size: 20),
                        ),
                        title: Text(item.title),
                        subtitle: Text('Par ${item.userName} • ${item.type}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _reject(context, item.id),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                                child: const Text('Rejeter'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _approve(context, item.id),
                                style: ElevatedButton.styleFrom(backgroundColor: AppConfig.accentFound),
                                child: const Text('Approuver'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all_rounded, size: 64, color: AppConfig.accentFound),
          const SizedBox(height: 16),
          const Text(
            'Toutes les annonces sont validées !',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _approve(BuildContext context, String id) async {
    final ok = await context.read<ItemsProvider>().approveItem(id);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annonce approuvée')));
    }
  }

  void _reject(BuildContext context, String id) async {
    final ok = await context.read<ItemsProvider>().rejectItem(id);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annonce rejetée')));
    }
  }
}
