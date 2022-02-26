class Chat {
  final DateTime? savedTime;
  final String? chatID;

  Chat({this.savedTime, this.chatID});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      savedTime: json['savedTime'] != null ? json['savedTime'].toDate() : null,
      chatID: json['chatID'] != null ? json['chatID'] : null,
    );
  }
}
