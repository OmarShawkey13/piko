class MessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final int timestamp;
  final bool seen;
  final String id;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.seen,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": timestamp,
      "seen": seen,
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map["senderId"],
      receiverId: map["receiverId"],
      text: map["text"],
      imageUrl: map["imageUrl"],
      timestamp: map["timestamp"],
      seen: map["seen"] ?? false,
    );
  }
}
