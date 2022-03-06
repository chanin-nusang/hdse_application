// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dialogflow_grpc/generated/google/protobuf/api.pb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/models/chat.dart';
import 'package:hdse_application/models/message.dart';
import 'package:hdse_application/screen/chatbot/archived_chat_list_screen.dart';
import 'package:hdse_application/screen/home_screen.dart';
import 'package:hdse_application/blocs/speech_to_text.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:animate_icons/animate_icons.dart';

class ArchivedChatScreen extends StatefulWidget {
  ArchivedChatScreen({Key? key, @required this.chat}) : super(key: key);
  Chat? chat;
  @override
  _ArchivedChatScreenState createState() => _ArchivedChatScreenState();
}

class _ArchivedChatScreenState extends State<ArchivedChatScreen>
    with SingleTickerProviderStateMixin {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<ChatMessage> _messages = <ChatMessage>[];
  List<String> suggestWord = [];
  bool suggestWordInit = true;
  stt.SpeechToText? _speech;
  String? _speechText;
  double _confidence = 1.0;
  bool _isRecording = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = 0;
  double level = 0.0;
  List<LocaleName> _localeNames = [];
  String? suggestLink;
  var speechToTextBloc;
  List<Message>? messagesList;
  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    speechToTextBloc = Provider.of<SpeechToTextService>(context, listen: false);
    fetchMessage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchMessage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("messages")
        .doc(widget.chat!.chatID)
        .collection("messages")
        .get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    messagesList = allData
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    messageToChatMessage();
    // if (result['messages'] != null) {
    //   var chatMap = result['messages'] as List;
    //   chatList = chatMap.map((chat) => Chat.fromJson(chat)).toList();
    // } else
    //   chatListIsEmpty = true;
  }

  void messageToChatMessage() {
    messagesList!.forEach((element) {
      var suggestLinkSplited = element.messageText!.split("@");
      if (suggestLinkSplited.length == 2) {
        setState(() {
          suggestLink = suggestLinkSplited[1];
          suggestWord = ["ดูเพิ่มเติม"];
        });

        print(suggestLink);
      } else {
        suggestLink = null;
      }
      var textMessageSplited = suggestLinkSplited[0].split("#");
      var textLineSplited = textMessageSplited[0].split("/n");
      if (element.sentBy == "bot") {
        ChatMessage botMessage = ChatMessage(
          text: textLineSplited,
          name: "น้องบอท",
          type: false,
        );
        setState(() {
          _messages.insert(0, botMessage);
        });
      } else {
        ChatMessage message = ChatMessage(
          text: textLineSplited,
          name: "คุณ",
          type: true,
        );
        setState(() {
          _messages.insert(0, message);
        });
      }
    });
  }

  _showDeleteChatDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.delete_forever_outlined,
                  size: 40,
                  color: Colors.green[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ยืนยันที่จะลบการสนทนานี้ หากลบแล้วจะไม่สามารถกู้คืนได้',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text(
                          "ยกเลิก",
                          style: TextStyle(fontSize: 17, color: Colors.green),
                        )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        onPressed: () async {
                          try {
                            print('chatID : ' + widget.chat!.chatID!);
                            await FirebaseFirestore.instance
                                .collection("messages")
                                .doc(widget.chat!.chatID)
                                .collection('messages')
                                .get()
                                .then((snapshot) {
                              for (DocumentSnapshot ds in snapshot.docs) {
                                ds.reference.delete();
                              }
                            });
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(user!.uid)
                                .update({
                              'messages': FieldValue.arrayRemove([
                                {
                                  'chatID': widget.chat!.chatID,
                                  'savedTime': widget.chat!.savedTime
                                }
                              ])
                            });

                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.pop(context, false);
                            speechToTextBloc
                                .deleteChatList(widget.chat!.chatID);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("ลบการสนทนาเรียบร้อยแล้ว",
                                  style: GoogleFonts.sarabun(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              backgroundColor: Colors.green,
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "ไม่สามารถลบการสนทนานี้ได้ โปรดลองอีกครั้ง",
                                  style: GoogleFonts.sarabun(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                        child: Text(
                          "ลบ",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget suggestWordButton() {
    return Container(
      height: 45,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: suggestWord.length,
          itemBuilder: (BuildContext context, int index) => Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green[50])),
                      onPressed: () {
                        if (suggestWord[index].toString() == "ดูเพิ่มเติม") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewService(
                                        title: 'ดูข้อมูลเพิ่มเติม',
                                        link: suggestLink.toString(),
                                      )));
                        }
                      },
                      child: Text(
                        suggestWord[index],
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _showDeleteChatDialog(context);
              },
              icon: Icon(Icons.delete_rounded))
        ],
        title: Text("การสนทนาที่บันทึกไว้"),
      ),
      body: Consumer<SpeechToTextService>(builder: (context, speech, child) {
        return (messagesList == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Flexible(
                      child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length,
                  )),
                  suggestWord.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: suggestWordButton())
                      : Row(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.green)),
                          child: Text(
                              'บันทึกเมื่อ วันที่ ${widget.chat!.savedTime!.day}/${widget.chat!.savedTime!.month}/${widget.chat!.savedTime!.year + 543}  เวลา ${widget.chat!.savedTime!.hour.toString().padLeft(2, '0')}.${widget.chat!.savedTime!.minute.toString().padLeft(2, '0')} น.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.green[700])),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                              'ไม่สามารถสนทนากับแชทบอท ในรายการสนทนาที่บันทึกไว้ได้',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[800])),
                        )
                      ],
                    ),
                  )
                ],
              );
      }),
    );
  }
}

//------------------------------------------------------------------------------------
// The chat message balloon
//
//------------------------------------------------------------------------------------
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

  final List<String>? text;
  final String? name;
  final bool? type;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          foregroundImage: Image.asset(
            'assets/images/bot.png',
            width: 15,
            height: 15,
            fit: BoxFit.fill,
          ).image,
          backgroundColor: Colors.green[200],
        ),
      ),
      new Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.name!, style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 0; i < text!.length; i++)
              Container(
                constraints:
                    BoxConstraints(minHeight: 30, minWidth: 20, maxWidth: 264),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green[100],
                ),
                margin: const EdgeInsets.only(top: 5.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text![i]),
                ),
              )
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(this.name!, style: Theme.of(context).textTheme.subtitle1),
            Container(
              constraints:
                  BoxConstraints(minHeight: 30, minWidth: 20, maxWidth: 264),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green[100],
              ),
              margin: const EdgeInsets.only(top: 5.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(text![0]),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: _auth.currentUser?.photoURL == null
              ? Image.asset('assets/images/avatar.png').image
              : CachedNetworkImageProvider(_auth.currentUser!.photoURL!),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type! ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
