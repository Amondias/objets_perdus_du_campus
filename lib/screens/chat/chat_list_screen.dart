import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final messagesProvider = context.watch<MessagesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: messagesProvider.conversations.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: messagesProvider.conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final conv = messagesProvider.conversations[index];
                final myUid = auth.user!.uid;
                final otherName = conv.getOtherParticipantName(myUid);
                final otherPhoto = conv.getOtherParticipantPhoto(myUid);
                final unread = conv.getUnreadCountFor(myUid);

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(conversation: conv),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppConfig.primaryColor,
                    backgroundImage: otherPhoto != null ? NetworkImage(otherPhoto) : null,
                    child: otherPhoto == null 
                        ? Text(otherName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18))
                        : null,
                  ),
                  title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage.isEmpty ? 'Commencer la discussion' : conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unread > 0 ? Colors.white : Colors.white54,
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        ' • ${timeago.format(conv.lastMessageAt, locale: 'fr')}',
                        style: const TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                    ],
                  ),
                  trailing: unread > 0
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppConfig.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            'Pas encore de messages',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
