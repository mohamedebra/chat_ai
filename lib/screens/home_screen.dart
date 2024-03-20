
import 'package:chat_ai/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/chat_provider.dart';
import 'chat_hostory_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> screen = [
    const ChatHistoryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

//  int currentIndex = 0;

 // final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return  Consumer<ChatProvider>(
      builder: (BuildContext context, ChatProvider chatProvider, Widget? child) {
        return Scaffold(
        body: PageView(
          controller: chatProvider.pageController,
          children: screen,
          onPageChanged: (index){
            chatProvider.setCurrentIndex(newIndex: index);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: chatProvider.currentIndex,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: (index){
            chatProvider.setCurrentIndex(newIndex: index);
              chatProvider.pageController.jumpToPage(index);
            },
      
            items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history),label: 'Chat History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),
        ]),
      );
        },
    );

  }
}
