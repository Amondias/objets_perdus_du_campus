import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_config.dart';
import '../../models/item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isOwner = auth.user?.uid == item.userId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.photos.isNotEmpty
                  ? PageView.builder(
                      itemCount: item.photos.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          item.photos[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Container(
                      color: AppConfig.surfaceVariant,
                      child: Icon(
                        AppConfig.getCategoryById(item.category)?['icon'] ?? Icons.category,
                        size: 80,
                        color: Colors.white10,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.isLost
                              ? AppConfig.accentLost.withOpacity(0.1)
                              : AppConfig.accentFound.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isLost ? 'OBJET PERDU' : 'OBJET TROUVÉ',
                          style: TextStyle(
                            color: item.isLost ? AppConfig.accentLost : AppConfig.accentFound,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        timeago.format(item.createdAt, locale: 'fr'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.category_outlined, 'Catégorie', 
                      AppConfig.getCategoryById(item.category)?['name'] ?? 'Autre'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, 'Lieu', item.location.name),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  _buildUserSection(context),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: isOwner
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConfig.surfaceColor,
                border: const Border(top: BorderSide(color: AppConfig.dividerColor)),
              ),
              child: ElevatedButton(
                onPressed: () => _contactUser(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline),
                    SizedBox(width: 10),
                    Text('Contacter l\'annonceur'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConfig.primaryLight),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConfig.primaryColor,
            backgroundImage: item.userPhotoUrl != null ? NetworkImage(item.userPhotoUrl!) : null,
            child: item.userPhotoUrl == null 
                ? Text(item.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Annonceur', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _contactUser(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messagesProvider = context.read<MessagesProvider>();

    if (auth.user == null) return;

    final conversation = await messagesProvider.getOrCreateConversation(
      myUid: auth.user!.uid,
      myName: auth.user!.name,
      myPhotoUrl: auth.user!.photoUrl,
      otherUid: item.userId,
      otherName: item.userName,
      otherPhotoUrl: item.userPhotoUrl,
      itemId: item.id,
      itemTitle: item.title,
    );

    if (conversation != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    }
  }
}
