import 'dart:developer';
import 'package:chat_ai/widget/preview_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../provider/chat_provider.dart';
import '../utility/utilites.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController textEditingController = TextEditingController();

  final FocusNode textFocusNode = FocusNode();

  //init image picker
  final ImagePicker imagePicker = ImagePicker();

  @override
  void dispose() {
    textEditingController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage(
      {required String message,
      required ChatProvider chatProvider,
      required bool isTextOnly}) async {
    try {
      await chatProvider.senMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log('error : $e');
    } finally {
      textEditingController.clear();
      widget.chatProvider.setImageFillList(imageFillList: []);
      textFocusNode.unfocus();
    }
  }

  void pickImage() async {
    try {
      final image = await imagePicker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImageFillList(imageFillList: image);
    } catch (e) {
      log('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).textTheme.titleLarge!.color!)),
      child: Column(
        children: [
          if (hasImages) const PreviewImages(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // pick image
                  if (hasImages) {
                    showMyAnimatedDialog(
                        context: context,
                        title: 'Delete Images',
                        content: 'Are you sure you went to delete the images?',
                        actionText: 'Delete',
                        onActionPressed: (bool value) {
                          if (value) {
                            widget.chatProvider
                                .setImageFillList(imageFillList: []);
                          }
                        });
                  } else {
                    pickImage();
                  }
                },
                icon: Icon(hasImages ? Icons.delete : Icons.image),
              ),
              Expanded(
                  child: TextField(
                focusNode: textFocusNode,
                controller: textEditingController,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.chatProvider.isLoading ? null : (String val) {
                  if (val.isNotEmpty) {
                    sendChatMessage(
                        message: textEditingController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: hasImages ? false : true
                    );
                  }
                },
                decoration: InputDecoration.collapsed(
                    hintText: 'type a message', border: InputBorder.none),
              )),
              GestureDetector(
                onTap: widget.chatProvider.isLoading ? null : () {
                  //send the message
                  if (textEditingController.text.isNotEmpty) {
                    sendChatMessage(
                        message: textEditingController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: hasImages ? false : true);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.all(5),
                    child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
