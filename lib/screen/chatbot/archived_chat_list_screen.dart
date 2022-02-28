import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/speech_to_text.dart';
import 'package:hdse_application/screen/chatbot/archived_chat_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ArchivedChatListScreen extends StatefulWidget {
  const ArchivedChatListScreen({Key? key}) : super(key: key);

  @override
  _ArchivedChatListScreenState createState() => _ArchivedChatListScreenState();
}

class _ArchivedChatListScreenState extends State<ArchivedChatListScreen> {
  var speechToTextBloc;
  @override
  void initState() {
    speechToTextBloc = Provider.of<SpeechToTextService>(context, listen: false);
    speechToTextBloc.getChatList();
    super.initState();
  }

  @override
  void dispose() {
    speechToTextBloc.clearChatList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ประวัติการสนทนากับแชทบอท"),
        ),
        body: (speechToTextBloc.chatList == null &&
                speechToTextBloc.chatListIsEmpty == false)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<SpeechToTextService>(
                builder: (context, provider, Widget? child) {
                  return provider.chatListIsEmpty == true
                      ? Center(
                          child: Text(
                            'ไม่พบรายการสนทนาที่บันทึกไว้',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: provider.chatList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green[50]),
                                    ),
                                    onPressed: () {
                                      // print('inkwell ontap');
                                      // applicationBloc.getPlaceDetailToBloc(
                                      //     provider.placeResults[index].placeID);
                                      print('chatID : ' +
                                          provider.chatList[index].chatID!);
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            reverseDuration: const Duration(
                                                milliseconds: 250),
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: new ArchivedChatScreen(
                                                chat:
                                                    provider.chatList[index])),
                                      );
                                    },
                                    child: AchivedChatListTile(
                                      savedTime:
                                          provider.chatList[index].savedTime,
                                    ),
                                  ),
                                );
                              }),
                        );
                },
              ));
  }
}

class AchivedChatListTile extends StatelessWidget {
  const AchivedChatListTile({@required this.savedTime});

  final DateTime? savedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'การสนทนาที่บันทึกไว้',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'วันที่ ${savedTime!.day}/${savedTime!.month}/${savedTime!.year}  เวลา ${savedTime!.hour.toString().padLeft(2, '0')}.${savedTime!.minute.toString().padLeft(2, '0')} น.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                )
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[600],
          )
        ],
      ),
    );
  }
}
