import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/chat_provider.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: ()async{
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.prepareChatRoom(isNewChat: true, chatId: '');
          
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);


        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary
            ),

          ),
          child: const Padding(padding: EdgeInsets.all(8),
          child: Text('No Chat found, start a new chat'),),
        ),
      ),
    );
  }
}
