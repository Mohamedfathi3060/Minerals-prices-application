class MessageModel {
  final String? userId;
  final String? userEmail;
  final DateTime dateTime;
  final String? text;
  final String? username;

  MessageModel({
    this.username,
    this.userId,
    this.userEmail,
    DateTime? dateTime,
    this.text,
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "userId": userId,
      "userEmail": userEmail,
      "dateTime": dateTime.toIso8601String(),
      "text": text,
    };
  }

  // Create a MessageModel from JSON data
  factory MessageModel.fromJson(Map<String, dynamic> message) {
    return MessageModel(
      username: message['username']??'',
      userId: message['userId'] ?? '',
      userEmail: message['userEmail'] ?? '',
      dateTime: message['dateTime'] != null
          ? DateTime.parse(message['dateTime'])
          : DateTime.now(), // Default to now if no dateTime is provided
      text: message['text'] ?? '',
    );
  }
}
