import 'package:flutter/material.dart';

import '../models/message.dart';
import '../provider/chat_provider.dart';
import 'aassistant_message_widget.dart';
import 'my_message_widget.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key, required this.scrollController, required this.chatProvider});
  final ScrollController scrollController;
  final ChatProvider chatProvider;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: chatProvider.inChatMessage.length,
        itemBuilder: (context, index) {

          //
          final message = chatProvider.inChatMessage[index];
          return message.role == Role.user
              ? MyMessageWidget(message: message)
              : AssistantMessageWidget(
              message: message.message.toString());
        });
  }
}
