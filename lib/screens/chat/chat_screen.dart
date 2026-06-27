import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().startWatchingMessages(widget.conversation.id);
      final myUid = context.read<AuthProvider>().user!.uid;
      context.read<MessagesProvider>().markAsRead(widget.conversation.id, myUid);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final success = await context.read<MessagesProvider>().sendMessage(
      conversationId: widget.conversation.id,
      senderId: auth.user!.uid,
      senderName: auth.user!.name,
      senderPhotoUrl: auth.user!.photoUrl,
      text: text,
    );

    if (success) {
      _msgCtrl.clear();
      _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final messagesProvider = context.watch<MessagesProvider>();
    final myUid = auth.user!.uid;
    final otherName = widget.conversation.getOtherParticipantName(myUid);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherName),
            if (widget.conversation.itemTitle != null)
              Text(
                'Objet : ${widget.conversation.itemTitle}',
                style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messagesProvider.activeMessages.length,
              itemBuilder: (context, index) {
                final msg = messagesProvider.activeMessages[index];
                final isMe = msg.senderId == myUid;

                // Date header logic
                bool showDate = false;
                if (index == messagesProvider.activeMessages.length - 1) {
                  showDate = true;
                } else {
                  final prevMsg = messagesProvider.activeMessages[index + 1];
                  if (!_isSameDay(msg.createdAt, prevMsg.createdAt)) {
                    showDate = true;
                  }
                }

                return Column(
                  children: [
                    if (showDate) _buildDateHeader(msg.createdAt),
                    _MessageBubble(msg: msg, isMe: isMe),
                    if (index == 0) const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildDateHeader(DateTime date) {
    String text;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      text = "Aujourd'hui";
    } else if (dateToCheck == yesterday) {
      text = 'Hier';
    } else {
      text = DateFormat('d MMMM yyyy', 'fr').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppConfig.surfaceVariant,
        border: const Border(top: BorderSide(color: AppConfig.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: const InputDecoration(
                hintText: 'Écrire un message...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _send,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(backgroundColor: AppConfig.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppConfig.primaryColor : AppConfig.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(msg.createdAt),
                  style: TextStyle(color: isMe ? Colors.white70 : Colors.white30, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: msg.isRead ? Colors.blueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
