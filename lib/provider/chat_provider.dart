import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';
import '../api/api_service.dart';
import '../constants.dart';
import '../hive/boxes.dart';
import '../hive/chat_history_hive.dart';
import '../hive/settings.dart';
import '../hive/user_model.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages
  List<Message> inChatMessage = [];
  // page controller
  final PageController pageController = PageController();

  // images file list
  List<XFile>? imagesFileList = [];

  int currentIndex = 0;

  String currentChatId = '';

  GenerativeModel? model;

  GenerativeModel? textModel;

  GenerativeModel? visionModel;

  String modelType = 'gemini-pro';

  bool isLoading = false;


  // delete chat messages
  Future<void> deleteChatMessages({required String chatId}) async {
    // 1. check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessageBox}$chatId')) {
      // open the box
      await Hive.openBox('${Constants.chatMessageBox}$chatId');

      // delete all messages in the box
      await Hive.box('${Constants.chatMessageBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessageBox}$chatId').close();
    } else {
      // delete all messages in the box
      await Hive.box('${Constants.chatMessageBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessageBox}$chatId').close();
    }

    // get the current chatId, its its not empty
    // we check if its the same as the chatId
    // if its the same we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        inChatMessage.clear();
        notifyListeners();
      }
    }
  }


  Future<void> prepareChatRoom({required bool isNewChat,required String chatId})async{

    if(!isNewChat){
      final chatHistory = await loadMessageFromDB(chatId: chatId);

      inChatMessage.clear();

      for(var message in chatHistory){
        inChatMessage.add(message);
      }

      setCurrentChatId(newChatId: chatId);

    }
    else{
      inChatMessage.clear();
      setCurrentChatId(newChatId: chatId);
    }
  }



  void setCurrentIndex({required newIndex}){
    currentIndex = newIndex;
    notifyListeners();
  }

  Future<void> setInChatMessage({required String chatId}) async {
    // get message from hive database
    final messageFromDb = await loadMessageFromDB(chatId: chatId);

    for (var message in messageFromDb) {
      if (inChatMessage.contains(message)) {
        //'message already exists'
        log('message already exists');
        continue;
      }

      inChatMessage.add(message);
    }
    notifyListeners();
  }

  Future<List<Message>> loadMessageFromDB({required String chatId}) async {
    // open the box
    await Hive.openBox('${Constants.chatMessageBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessageBox}$chatId');
    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      // inChatMessage.add(message);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  void setImageFillList({required List<XFile> imageFillList}) {
    imagesFileList = imageFillList;
    notifyListeners();
  }

  //set the current model
  String setCurrentModel({required String newModel}) {
    modelType = newModel;
    notifyListeners();
    return newModel;
  }

  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      model = textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-pro'),
              apiKey: ApiService.apiKey);
    } else {
      model = visionModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: 'gemini-pro-vision'),
              apiKey: ApiService.apiKey);
    }
    notifyListeners();
  }

  void setCurrentChatId({required String newChatId}) {
    currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> senMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    // set the model
    await setModel(isTextOnly: isTextOnly);
    // set Loading
    setLoading(value: true);
    // get chatId
    String chatId = getChatId();
    // list of history messages
    List<Content> history = [];
    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the imagesUrl

    List<String> imagesUrl = getImagesUrl(isTextOnly: isTextOnly);
    final messagesBox =  await Hive.openBox('${Constants.chatMessageBox}$chatId');

    log('messagesBoxLength: ${messagesBox.keys.length}');

    final userMessageId =  messagesBox.keys.length;
    final assistantMessageId =  messagesBox.keys.length +1;

    log('userMessageId: $userMessageId');
    log('assistantMessageId: $assistantMessageId');
    final userMassage = Message(
        messageId: userMessageId.toString(),
        chatId: chatId,
        role: Role.user,
        message: StringBuffer(message),
        imagesUrls: imagesUrl,
        timeSent: DateTime.now());

    // add this message to the list on inChatMessages
    inChatMessage.add(userMassage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }
    // send the message to the model and wait for response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMassage: userMassage,
        modelMessageId: assistantMessageId.toString(),
        messagesBox: messagesBox
    );
  }
  // send the message to the model and wait for response

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMassage,
    required String modelMessageId,
    required Box messagesBox
  }) async {
    // start the chat
    final chatSession = model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );
    // get content

    final content = await getContent(message: message, isTextOnly: isTextOnly);


    // assistant message
    final assistantMessage = userMassage.copyWith(
        messageId: modelMessageId,
        role: Role.assistant,
        message: StringBuffer(),
        timeSent: DateTime.now());
    inChatMessage.add(assistantMessage);
    notifyListeners();

    // wait for stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      inChatMessage
          .firstWhere((element) =>
              element.messageId == assistantMessage.messageId &&
              element.role.name == Role.assistant.name)
          .message
          .write(event.text);
      notifyListeners();
    }, onDone: () async{


      // save message to hive DB
     await saveMessageToDB(
          chatId: chatId,
          userMessage: userMassage,
          assistantMessage: assistantMessage, messagesBox: messagesBox
      );
      //set Loading false
      setLoading(value: false);
    }).onError((error, stackTrace) {
      // set loading
      setLoading(value: false);
    });
  }

  // save message
  Future<void> saveMessageToDB(
      {required String chatId,
      required Message userMessage,
      required Message assistantMessage,
      required messagesBox
      }) async
  {
    // open the messages box
   // final messagesBox =  await Hive.openBox('${Constants.chatMessageBox}$chatId');

   // save the user message
   await messagesBox.add(userMessage.toMap());

   // save the assistant message
   await messagesBox.add(assistantMessage.toMap());
   // save chat history
   final chatHistoryBox = Boxes.getChatHistory();
   final chatHistory = ChatHistory(
       chatId: chatId,
       prompt: userMessage.message.toString(),
       response: assistantMessage.message.toString(),
       imagesUrls: userMessage.imagesUrls,
       timestamp: DateTime.now()
   );
   await chatHistoryBox.put(chatId, chatHistory);

   // close the box
    await messagesBox.close();
  }

  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final imageFuture = imagesFileList
          ?.map((imageFill) => imageFill.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFuture!);
      final promt = TextPart(message);
      final imagesParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([promt, ...imagesParts]);
    }
  }

  // get the imagesUrl
  List<String> getImagesUrl({required bool isTextOnly}) {
    List<String> imagesUrl = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrl.add(image.path);
      }
    }
    return imagesUrl;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isEmpty) {
      await setInChatMessage(chatId: chatId);

      for (var message in inChatMessage) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // init Hive
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    // register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      // open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }

  // send message
}
