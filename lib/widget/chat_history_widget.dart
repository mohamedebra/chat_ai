
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../hive/chat_history_hive.dart';
import '../provider/chat_provider.dart';
import '../utility/utilites.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({super.key, required this.chat});

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10,right: 10),
        leading: const CircleAvatar(
            radius:30,
            child: Icon(Icons.chat)),
        title:  Text(chat.prompt,maxLines: 1,),
        subtitle: Text(chat.response , maxLines: 2,),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: ()async{
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.prepareChatRoom(isNewChat: false, chatId: chat.chatId);
          
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);


        },
        onLongPress: (){
          showMyAnimatedDialog(
              context: context,
              title: 'Delete Chat',
              content: 'Are you sure you went delete this chat?',
              actionText: 'Delete',
              onActionPressed: (val)async{
                if(val){
                  // Utilites
                  await context.read<ChatProvider>().deleteChatMessages(chatId: chat.chatId);
                  await chat.delete();
                }
              }
          );
        },
      ),
    );
  }
}
