class Message {
  final DateTime? sentAt;
  final String? sentBy;
  final String? messageText;

  Message({this.sentAt, this.sentBy, this.messageText});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        sentAt: json['sentAt'] != null ? json['sentAt'].toDate() : null,
        sentBy: json['sentBy'] != null ? json['sentBy'] : null,
        messageText: json['formatted_address'] != null
            ? json['formatted_address']
            : null);
  }
}
