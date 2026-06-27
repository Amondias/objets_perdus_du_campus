import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_config.dart';
import '../../providers/items_provider.dart';
import '../../models/item_model.dart';
import 'item_detail_screen.dart';
import 'add_item_screen.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objets du Campus'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un objet...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: AppConfig.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => itemsProvider.setSearchQuery(value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildTypeChip(context, 'all', 'Tous'),
                    _buildTypeChip(context, 'lost', 'Perdus'),
                    _buildTypeChip(context, 'found', 'Trouvés'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildFilterChip(context, 'all', 'Toutes catégories'),
                    ...AppConfig.categories.map((cat) => _buildFilterChip(
                          context,
                          cat['id'],
                          cat['name'],
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: itemsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemsProvider.filteredItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: itemsProvider.filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = itemsProvider.filteredItems[index];
                    return _ItemCard(item: item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Publier'),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, String label) {
    final itemsProvider = context.read<ItemsProvider>();
    final isSelected = itemsProvider.selectedType == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => itemsProvider.filterByType(type),
        selectedColor: type == 'lost' 
            ? AppConfig.accentLost.withOpacity(0.3) 
            : (type == 'found' ? AppConfig.accentFound.withOpacity(0.3) : AppConfig.primaryColor.withOpacity(0.3)),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String id, String label) {
    final itemsProvider = context.read<ItemsProvider>();
    final isSelected = itemsProvider.selectedCategory == id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => itemsProvider.filterByCategory(id),
        selectedColor: AppConfig.primaryColor.withOpacity(0.2),
        checkmarkColor: AppConfig.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppConfig.primaryColor : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'Aucun objet trouvé',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final category = AppConfig.getCategoryById(item.category);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image placeholder or first photo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppConfig.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  image: item.photos.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.photos.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.photos.isEmpty
                    ? Icon(category?['icon'] ?? Icons.category,
                        color: Colors.white24, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isLost
                                ? AppConfig.accentLost.withOpacity(0.1)
                                : AppConfig.accentFound.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isLost ? 'PERDU' : 'TROUVÉ',
                            style: TextStyle(
                              color: item.isLost
                                  ? AppConfig.accentLost
                                  : AppConfig.accentFound,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(item.createdAt, locale: 'fr'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.white38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
