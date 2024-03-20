import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../provider/chat_provider.dart';

class PreviewImages extends StatelessWidget {
  const PreviewImages({super.key, this.message});
  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context,chatProvider,child){
      final messageToShow = message != null ? message!.imagesUrls : chatProvider.imagesFileList;
      final padding = message != null ? EdgeInsets.zero : const EdgeInsets.only(left: 8,right: 8);
      return Padding(padding: padding,
      child: SizedBox(
        height: 80,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messageToShow!.length,
            itemBuilder: (context,index){
              return Padding(
                padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(message != null ? message!.imagesUrls[index] : chatProvider.imagesFileList![index].path),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
      ),);
    });
  }
}
