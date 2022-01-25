import 'package:flutter/cupertino.dart';
import 'package:hdse_application/screen/chatbot_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService with ChangeNotifier {
  bool isRecording = false;
  // bool get isRecording => _isRecording;
  stt.SpeechToText? _speech = stt.SpeechToText();
  String? _speechText = 'กำลังฟัง...';
  double? level = 0.0;
  double _confidence = 1.0;
  bool isError = false;
  bool hasSpeech = false;

  void setIsRecordingToFalse() {
    isRecording = false;
    notifyListeners();
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
