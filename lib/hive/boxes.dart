
import 'package:chat_ai/hive/chat_history_hive.dart';
import 'package:chat_ai/hive/settings.dart';
import 'package:chat_ai/hive/user_model.dart';
import 'package:hive/hive.dart';

import '../constants.dart';

class Boxes {
  static Box<ChatHistory> getChatHistory() => Hive.box<ChatHistory>(Constants.chatHistoryBox);
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);
  static Box<Settings> getSetting() => Hive.box<Settings>(Constants.settingsBox);
}