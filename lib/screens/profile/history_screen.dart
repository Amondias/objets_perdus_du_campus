import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_config.dart';
import '../../providers/items_provider.dart';
import '../items/item_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final resolvedItems = itemsProvider.getResolvedItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des retrouvés'),
      ),
      body: resolvedItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: resolvedItems.length,
              itemBuilder: (context, index) {
                final item = resolvedItems[index];
                return ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppConfig.accentFound.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppConfig.accentFound),
                  ),
                  title: Text(item.title),
                  subtitle: Text('Retrouvé ${timeago.format(item.updatedAt, locale: 'fr')}'),
                  trailing: const Icon(Icons.chevron_right),
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
          Icon(Icons.history_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            'Aucun objet dans l\'historique',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
