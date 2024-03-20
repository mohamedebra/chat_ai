import 'package:chat_ai/widget/preview_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/message.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,

        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            if(message.imagesUrls.isNotEmpty)
               PreviewImages(message: message,),
            MarkdownBody(
              selectable: true,
              data: message.message.toString(),
              // styleSheet: MarkdownStyleSheet(
              //   p: Theme.of(context).textTheme.bodyText1
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
