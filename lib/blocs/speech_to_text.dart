import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/models/chat.dart';
import 'package:hdse_application/models/message.dart';
import 'package:hdse_application/screen/chatbot/chatbot_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

class SpeechToTextService with ChangeNotifier {
  var uuid = Uuid();
  bool isRecording = false;
  // bool get isRecording => _isRecording;
  stt.SpeechToText? _speech = stt.SpeechToText();
  String? _speechText = 'กำลังฟัง...';
  double? level = 0.0;
  double _confidence = 1.0;
  bool isError = false;
  bool hasSpeech = false;
  List<Message> currentMessages = [];
  List<Message> archivedChat = [];
  List<Chat> chatList = [];
  bool chatListIsEmpty = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void setIsRecordingToFalse() {
    isRecording = false;
    notifyListeners();
  }

  void deleteChatList(String chatID) {
    chatList.removeWhere((element) => element.chatID == chatID);
    if (chatList.length == 0) chatListIsEmpty = true;
    notifyListeners();
  }

  void clearChatList() {
    chatListIsEmpty = false;
    chatList = [];
  }

  void getChatList() async {
    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get(); //get the data
    var result = data.data()!;
    var mes = result['messages'] as List;
    if (result['messages'] != null && mes.length > 0) {
      var chatMap = result['messages'] as List;
      chatList = chatMap.map((chat) => Chat.fromJson(chat)).toList();
    } else
      chatListIsEmpty = true;
    notifyListeners();
  }

  void storeMessage(String message, String id) {
    Message mes =
        Message(sentAt: DateTime.now(), sentBy: id, messageText: message);
    currentMessages.add(mes);
  }

  void saveMessageToFireStore(BuildContext context) async {
    if (_auth.currentUser != null) {
      var keyID = uuid.v1();
      var userID = _auth.currentUser!.uid;
      try {
        currentMessages.asMap().forEach((index, value) async {
          await FirebaseFirestore.instance
              .collection("messages")
              .doc(keyID)
              .collection('messages')
              .doc(index.toString())
              .set({
            'sentAt': value.sentAt,
            'sentBy': value.sentBy,
            'messageText': value.messageText
          });
        });
        // await FirebaseFirestore.instance
        //     .collection("messages")
        //     .doc(keyID)
        //     .set({'savedTime': DateTime.now()});
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userID)
            .update({
          'messages': FieldValue.arrayUnion([
            {'chatID': keyID, 'savedTime': DateTime.now()}
          ])
        });
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("บันทึกการสนทนาสำเร็จ",
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18))),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("ไม่สามารถบันทึกการสนทนาได้ โปรดลองอีกครั้ง",
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18))),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("กรุณาลงชื่อเข้าใช้งาน",
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(color: Colors.white, fontSize: 18))),
        backgroundColor: Colors.red,
      ));
    }
  }

  void setIsRecordingToTrue() {
    isRecording = true;
    notifyListeners();
  }

  bool getIsRecording() {
    return isRecording;
  }

  String? getSpeechText() {
    return _speechText;
  }

  void clearCurrentMessages() {
    currentMessages = [];
  }

  bool getIsError() => isError;

  void setSpeechText(String text) => _speechText = text;

  Future<void> initSpeechState() async {
    hasSpeech = await _speech!.initialize(
      onError: (val) {
        isRecording = false;
        print('onError: $val');
      },
      onStatus: (val) {
        print('onStatus: $val');
        if (val.toString() == "notListening") {
          print("SpeechToTextService onStatus $val (should be notListening)");
          isRecording = false;
          _speechText = 'กำลังฟัง...';
        }
      },
      // debugLogging: true,
    );
  }
}
