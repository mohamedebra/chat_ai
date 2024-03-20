import 'package:chat_ai/utility/utilites.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/chat_provider.dart';
import '../widget/bottom_chat_feild.dart';
import '../widget/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent > 0.0) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder:
          (BuildContext context, ChatProvider chatProvider, Widget? child) {
        if (chatProvider.inChatMessage.isNotEmpty) {
          scrollToBottom();
        }
        chatProvider.addListener(() {
          if (chatProvider.inChatMessage.isNotEmpty) {
            scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Chat with Gemini'),
            actions: [
              if (chatProvider.inChatMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      child: IconButton(onPressed: () {

                        showMyAnimatedDialog(
                            context: context,
                            title: 'Start New Chat',
                            content: 'Are you sure went to start a new chat',
                            actionText: 'Yes',
                            onActionPressed: (value)async{
                              if(value){
                                await chatProvider.prepareChatRoom(isNewChat: true, chatId: '');


                              }
                            }
                        );
                      }, icon: Icon(Icons.add))),
                )
            ],
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                    child: chatProvider.inChatMessage.isEmpty
                        ? const Center(
                            child: Text('No messages yet'),
                          )
                        : ChatList(
                            scrollController: scrollController,
                            chatProvider: chatProvider,
                          )),
                BottomChatField(
                  chatProvider: chatProvider,
                ),
              ],
            ),
          )),
        );
      },
    );
  }
}
