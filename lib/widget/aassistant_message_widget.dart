import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssistantMessageWidget extends StatelessWidget {
  const AssistantMessageWidget({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .9,

        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child:
        message.isEmpty ? const SizedBox(
          width: 50,
          child: SpinKitThreeBounce(
            color: Colors.blueGrey,
            size: 20,
          ),
        ):

        MarkdownBody(
          selectable: true,
          data: message,
          styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyText1
          ),
        ),
      ),
    );
  }
}
