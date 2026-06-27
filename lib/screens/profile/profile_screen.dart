import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/items_provider.dart';
import '../admin/validation_screen.dart';
import '../items/item_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final itemsProvider = context.watch<ItemsProvider>();
    final user = auth.user;

    if (user == null) return const Center(child: Text('Non connecté'));

    final myItems = itemsProvider.getUserItems(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConfig.primaryColor,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null 
                        ? Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white38)),
                  const SizedBox(height: 8),
                  if (user.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      ),
                      child: const Text('Administrateur', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Admin Action
            if (user.isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  tileColor: AppConfig.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.amber),
                  title: const Text('Valider les publications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ValidationScreen()));
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mes annonces', style: Theme.of(context).textTheme.titleLarge),
                  Text('${myItems.length}', style: const TextStyle(color: AppConfig.primaryLight, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (myItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('Vous n\'avez pas encore publié d\'annonce.', style: TextStyle(color: Colors.white24)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myItems.length,
                itemBuilder: (context, index) {
                  final item = myItems[index];
                  return ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
                    leading: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppConfig.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(AppConfig.getCategoryById(item.category)?['icon'] ?? Icons.category, size: 20, color: Colors.white38),
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.status == 'active' ? 'En ligne' : (item.status == 'pending' ? 'En attente' : 'Résolu')),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
