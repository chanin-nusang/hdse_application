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
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dialogflow_grpc/generated/google/protobuf/api.pb.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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

// TODO import Dialogflow
DialogflowGrpcV2Beta1? dialogflow;

class ChatbotScreen extends StatefulWidget {
  ChatbotScreen({Key? key}) : super(key: key);
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with SingleTickerProviderStateMixin {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  List<String> word = [
    "ปัสสาวะราด",
    "หกล้ม",
    "เดินลำบาก",
    "ทรงตัวไม่ดี",
    "ก้าวขาลำบาก",
    "กลั้นปัสสาวะไม่อยู่",
    "หลงทิศทาง",
    "ลืมสิ่งของบ่อย ๆ",
    "แขนขาอ่อนแรง",
    "กลืนลำบาก",
    "ข้อบวม",
    "ไอมีเสมหะ",
    "เจ็บหน้าอก",
    "ข้อเสื่อม"
  ];
  List<String> suggestWord = [];
  bool suggestWordInit = true;
  stt.SpeechToText? _speech;
  String? _speechText;
  double _confidence = 1.0;
  RecorderStream _recorder = RecorderStream();
  StreamSubscription? _recorderStatus;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  bool _isRecording = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = 0;
  double level = 0.0;
  AnimateIconController? animateController;
  // TODO DialogflowGrpc class instance
  List<LocaleName> _localeNames = [];
  String? suggestLink;
  var speechToTextBloc;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _speechText = 'กำลังฟัง...';
    _speech = stt.SpeechToText();
    word.shuffle();
    initPlugin();
    animateController = AnimateIconController();
    speechToTextBloc = Provider.of<SpeechToTextService>(context, listen: false);
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _audioStreamSubscription?.cancel();
    speechToTextBloc.clearCurrentMessages();
    super.dispose();
  }

  checkMicrophonePermission() async {
    var microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus.isDenied) {
      await Permission.microphone.request();
      microphoneStatus = await Permission.microphone.status;
      if (microphoneStatus.isDenied) {
        animateController!.animateToStart();
        _showMicrophonePermissionDeniedDialog();
      } else {
        if (!_speech!.isAvailable) {
          SpeechToTextService().initSpeechState().then((value) => _listen());
        } else
          _listen();
      }
    } else {
      if (!_speech!.isAvailable) {
        SpeechToTextService().initSpeechState().then((value) => _listen());
        _listen();
      } else
        _listen();
    }
  }

  _showMicrophonePermissionDeniedDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.mic_off_outlined,
                  size: 40,
                  color: Colors.red[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ไม่ได้รับสิทธิ์ให้เข้าถึงไมโครโฟน กดปุ่ม เปิดการตั้งค่า ที่เมนู "สิทธิ์" มองหา "ไมโครโฟน" แล้วเลือก "อนุญาตขณะมีการใช้แอปเท่านั้น"',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await AppSettings.openAppSettings();
                        },
                        child: Text(
                          "เปิดการตั้งค่า",
                          style: TextStyle(fontSize: 17),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void setIsRecording() {
    print("yahoooooooooo");
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void setSpeechText() {
    print("yaheeeeeeeeee : $_speechText");
    handleSubmitted(_speechText);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.bluetoothConnect, Permission.bluetooth].request();
    print(statuses[Permission.bluetoothConnect]);
    print(statuses[Permission.bluetooth]);
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted)
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
    });

    await Future.wait([_recorder.initialize()]);

    // TODO Get a Service account
    // Get a Service account
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/credentials.json'))}');
    // Create a DialogflowGrpc Instance
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
    firstSubmmit();
  }

  void stopStream() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
  }

  void firstSubmmit() async {
    DetectIntentResponse? data =
        await dialogflow?.detectIntent("สวัสดี", 'en-US');

    var fulfillmentText = data?.queryResult.fulfillmentText.split("/n");

    if (fulfillmentText != null) {
      ChatMessage botMessage = ChatMessage(
        text: fulfillmentText,
        name: "น้องบอท",
        type: false,
      );
      if (user != null)
        speechToTextBloc.storeMessage(data?.queryResult.fulfillmentText, 'bot');
      setState(() {
        _messages.insert(0, botMessage);
        suggestWord = word;
      });
    }
  }

  void handleSubmitted(text) async {
    print("handleSubmitted : ${text ?? "null"}");
    var textInit = "กำลังฟัง...";
    if (text.toString() != textInit && text.toString() != '' && text != null) {
      print("handleSubmitted : " + text);
      _textController.clear();
      var textSplited = text!.split("/n");
      //TODO Dialogflow Code
      ChatMessage message = ChatMessage(
        text: textSplited,
        name: "คุณ",
        type: true,
      );

      if (mounted) {
        if (user != null) speechToTextBloc.storeMessage(text, user!.uid);

        setState(() {
          _messages.insert(0, message);
        });
      }

      DetectIntentResponse? data =
          await dialogflow?.detectIntent(text, 'en-US');
      var suggestLinkSplited = data?.queryResult.fulfillmentText.split("@");
      if (suggestLinkSplited?.length == 2) {
        suggestLink = suggestLinkSplited?[1];
        print(suggestLink);
      } else {
        suggestLink = null;
      }
      var fulfillmentText = suggestLinkSplited![0].toString().split("#");
      if (fulfillmentText.length == 2) {
        if (fulfillmentText[1].length != 0) {
          List<String>? newSuggestWord = fulfillmentText[1].split(":");
          setState(() {
            suggestWord = newSuggestWord;
          });
        } else {
          setState(() {
            suggestWord = word;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            suggestWord = word;
          });
        }
      }

      if (suggestLink != null) {
        setState(() {
          suggestWord = ["ดูเพิ่มเติม"];
        });
      }

      var fulfillmentSplited = fulfillmentText[0].split("/n");

      if (fulfillmentSplited != null) {
        ChatMessage botMessage = ChatMessage(
          text: fulfillmentSplited,
          name: "น้องบอท",
          type: false,
        );

        if (mounted) {
          if (user != null)
            speechToTextBloc.storeMessage(
                data?.queryResult.fulfillmentText, 'bot');

          setState(() {
            _messages.insert(0, botMessage);
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        _speechText = 'กำลังฟัง...';
        _isRecording = false;
        level = 0.0;
      });
    }
  }

  // void handleStream() async {
  //   _recorder.start();

  //   _audioStream = BehaviorSubject<List<int>>();
  //   _audioStreamSubscription = _recorder.audioStream.listen((data) {
  //     print(data);
  //     _audioStream?.add(data);
  //   });

  //   // TODO Create SpeechContexts
  //   // Create an audio InputConfig
  //   var biasList = SpeechContextV2Beta1(phrases: [
  //     'Dialogflow CX',
  //     'Dialogflow Essentials',
  //     'Action Builder',
  //     'HIPAA'
  //   ], boost: 20.0);

  //   // See: https://cloud.google.com/dialogflow/es/docs/reference/rpc/google.cloud.dialogflow.v2#google.cloud.dialogflow.v2.InputAudioConfig
  //   var config = InputConfigV2beta1(
  //       encoding: 'AUDIO_ENCODING_LINEAR_16',
  //       languageCode: 'en-US',
  //       sampleRateHertz: 16000,
  //       singleUtterance: false,
  //       speechContexts: [biasList]);

  //   // TODO Make the streamingDetectIntent call, with the InputConfig and the audioStream
  //   // TODO Get the transcript and detectedIntent and show on screen

  //   final responseStream =
  //       dialogflow?.streamingDetectIntent(config, _audioStream!);
  //   // Get the transcript and detectedIntent and show on screen
  //   responseStream?.listen((data) {
  //     //print('----');
  //     setState(() {
  //       //print(data);
  //       String transcript = data.recognitionResult.transcript;
  //       String queryText = data.queryResult.queryText;
  //       var fulfillmentText = data.queryResult.fulfillmentText.split("/n");
  //       var queryTextSplited = queryText.split("/n");

  //       if (fulfillmentText.isNotEmpty) {
  //         ChatMessage message = new ChatMessage(
  //           text: queryTextSplited,
  //           name: "You",
  //           type: true,
  //         );

  //         ChatMessage botMessage = new ChatMessage(
  //           text: fulfillmentText,
  //           name: "Bot",
  //           type: false,
  //         );

  //         _messages.insert(0, message);
  //         _textController.clear();
  //         _messages.insert(0, botMessage);
  //       }
  //       if (transcript.isNotEmpty) {
  //         _textController.text = transcript;
  //       }
  //     });
  //   }, onError: (e) {
  //     //print(e);
  //   }, onDone: () {
  //     //print('done');
  //   });
  // }

  void _listen() async {
    if (!Provider.of<SpeechToTextService>(context, listen: false).isRecording) {
      // bool available = await _speech!.initialize(
      //   onStatus: (val) {
      //     if (val.toString() == "notListening") {
      //       print("val == $val (should be notListening)");

      //       if (mounted) {
      //         handleSubmitted(_speechText);
      //         _isRecording = false;
      //       }

      //       print("1. _isRecording = $_isRecording");
      //       print("_speechText : " + _speechText!);
      //     }
      //     if (val.toString() == "done") {
      //       print("val == $val (should be done)");
      //       _isRecording = false;
      //       print("done _isRecording = $_isRecording");
      //     }
      //     print('onStatus _speechText : $_speechText');
      //     print('onStatus: $val');
      //   },
      //   onError: (val) => print('onError: $val'),
      // );
      // if (available) {

      if (_speech!.isAvailable) {
        setState(() {
          _isRecording = true;
          Provider.of<SpeechToTextService>(context, listen: false)
              .setIsRecordingToTrue();
        });
        // _localeNames = await _speech!.locales();
        // print("_localeNames : " + _localeNames.toString());
        print("2. _isRecording : $_isRecording");
        _speech!.listen(
          localeId: "th_TH",
          onSoundLevelChange: (level) {
            soundLevelListener(level);
          },
          onResult: (val) => setState(() {
            _speechText = val.recognizedWords;
            print("checkkkk: " +
                Provider.of<SpeechToTextService>(context, listen: false)
                    .isRecording
                    .toString());
            print("onResult _speechText : $_speechText");
            print("onResult val.recognizedWords : " + val.recognizedWords);
            // print('onResult available : $available');
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
            print("_speech!.isListening : " + _speech!.isListening.toString());
            if (
                // Provider.of<SpeechToTextService>(context, listen: false)
                //           .isRecording ==
                //       false
                _speech!.isListening == false) {
              setState(() {
                _isRecording = false;
                animateController!.animateToStart();
                Provider.of<SpeechToTextService>(context, listen: false)
                    .setIsRecordingToFalse();
                level = 0.0;
                handleSubmitted(_speechText);
              });
            }
          }),
        );
      }

      // .then((value) => setState(() {
      //       _isRecording = false;
      //       print("_isRecording : false");
      //     }));
      // }
    } else {
      setState(() {
        _speechText = 'กำลังฟัง...';
        _isRecording = false;
        animateController!.animateToStart();
        Provider.of<SpeechToTextService>(context, listen: false)
            .setIsRecordingToFalse();
        level = 0.0;
      });
      print("3. _isRecording : ${_isRecording}");
      if (_speech!.isAvailable) _speech!.stop();
    }
  }

  soundLevelListener(double levelll) {
    print("level : $level");
    // minSoundLevel = min(minSoundLevel, level);
    // maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      if (levelll < 0) {
        this.level = 0;
      } else {
        this.level = levelll;
      }
    });
  }
  // The chat interface
  //
  //------------------------------------------------------------------------------------\

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
                        } else {
                          handleSubmitted(suggestWord[index]);
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

  Widget speechTextBox() {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
      //height: 45,
      width: 300,
      constraints: BoxConstraints(minHeight: 45, minWidth: 300, maxHeight: 200),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
        child: Text(
          _speechText!,
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  _showAskingMessageStoreDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.mark_chat_unread_outlined,
                  size: 40,
                  color: Colors.green[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ท่านต้องการบันทึกการสนทนาในครั้งนี้ไว้หรือไม่',
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
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          "ออก",
                          style: TextStyle(fontSize: 17, color: Colors.red),
                        )),
                    ElevatedButton(
                        onPressed: () {
                          speechToTextBloc.saveMessageToFireStore(context);
                        },
                        child: Text(
                          "บันทึก",
                          style: TextStyle(fontSize: 17),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (speechToTextBloc.currentMessages.length <= 1)
          Navigator.pop(context, false);
        else
          _showAskingMessageStoreDialog(context);

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  if (user != null)
                    Navigator.push(
                      context,
                      PageTransition(
                          duration: const Duration(milliseconds: 250),
                          reverseDuration: const Duration(milliseconds: 250),
                          type: PageTransitionType.rightToLeft,
                          child: new ArchivedChatListScreen()),
                    );
                  else
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("กรุณาลงชื่อเข้าใช้",
                          style: GoogleFonts.sarabun(
                              textStyle: TextStyle(
                                  color: Colors.white, fontSize: 18))),
                      backgroundColor: Colors.red,
                    ));
                },
                icon: Icon(Icons.chat_rounded))
          ],
          // leading: new IconButton(
          //     icon: new Icon(Icons.arrow_back),
          //     onPressed: () {
          //       _speech!.cancel();
          //       Navigator.pop(context, true);
          //     }),
          title: Text("แชทบอท"),
        ),
        body: Column(children: <Widget>[
          Flexible(
              child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          )),
          // Divider(height: 1.0),
          suggestWord.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: !context.watch<SpeechToTextService>().isRecording
                      ? suggestWordButton()
                      : speechTextBox())
              : Row(),
          Consumer<SpeechToTextService>(builder: (context, speech, child) {
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 5, left: 10, top: 10, bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: .26,
                                  spreadRadius: level * 3,
                                  color: Colors.green[300]!.withOpacity(.3))
                            ]),
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        child: AvatarGlow(
                          animate: speech.isRecording,
                          glowColor: Theme.of(context).primaryColor,
                          endRadius: 150,
                          duration: const Duration(milliseconds: 2000),
                          repeatPauseDuration:
                              const Duration(milliseconds: 100),
                          repeat: true,
                          child: FloatingActionButton(
                            backgroundColor: speech.isRecording
                                ? Colors.green
                                : Colors.white,
                            child: AnimateIcons(
                              startIcon: Icons.mic,
                              endIcon: Icons.mic_off,

                              controller: animateController!,
                              // add this tooltip for the start icon
                              startTooltip: 'Icons.add_circle',
                              // add this tooltip for the end icon
                              endTooltip: 'Icons.add_circle_outline',
                              size: 30.0,
                              onStartIconPress: () {
                                print("Clicked on Add Icon");
                                checkMicrophonePermission();
                                return true;
                              },
                              onEndIconPress: () {
                                print("Clicked on Close Icon");
                                checkMicrophonePermission();
                                return true;
                              },
                              duration: Duration(milliseconds: 250),
                              startIconColor: Colors.green,
                              endIconColor: Colors.white,
                              clockwise: false,
                            ),
                            // Icon(
                            //   speech.isRecording ? Icons.mic_off : Icons.mic,
                            //   size: 30,
                            //   color: speech.isRecording
                            //       ? Colors.white
                            //       : Colors.green,
                            // ),
                            onPressed: checkMicrophonePermission,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, right: 15, top: 10, bottom: 10),
                        child: Container(
                            margin: EdgeInsets.only(
                                left: 0, top: 0, right: 0, bottom: 0),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).cardColor),
                            child: IconTheme(
                              data: IconThemeData(
                                  color: Theme.of(context).accentColor),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        controller: _textController,
                                        onSubmitted: handleSubmitted,
                                        decoration: InputDecoration.collapsed(
                                            hintText: "พิมพ์ข้อความ..."),
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: IconButton(
                                            icon: Icon(Icons.send),
                                            onPressed: () {
                                              if (_textController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "กรุณาป้อนข้อความ หรือ เลือกคำแนะนำ",
                                                      style: GoogleFonts.sarabun(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18))),
                                                  backgroundColor: Colors.red,
                                                ));
                                              } else {
                                                handleSubmitted(
                                                    _textController.text);
                                              }
                                            }))
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            );
          })
        ]),
      ),
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
    print("Text in otherMessage : ${text ?? "null"}");
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
    print("Text in myMessage : ${text ?? "null"}");
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
