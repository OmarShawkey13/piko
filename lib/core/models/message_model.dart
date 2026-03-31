class MessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final int timestamp;
  final bool seen;
  final String id;
  final String? fileSize;
  final String? replyToId;
  final String? replyText;
  final String? replySenderName;
  final bool isUploading;
  final String? localPath;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.seen,
    required this.id,
    this.fileSize,
    this.replyToId,
    this.replyText,
    this.replySenderName,
    this.isUploading = false,
    this.localPath,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": timestamp,
      "seen": seen,
      "fileSize": fileSize,
      "replyToId": replyToId,
      "replyText": replyText,
      "replySenderName": replySenderName,
      "isUploading": isUploading,
      "localPath": localPath,
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map["senderId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      text: map["text"] ?? "",
      imageUrl: map["imageUrl"],
      timestamp: map["timestamp"] ?? 0,
      seen: map["seen"] ?? false,
      fileSize: map["fileSize"],
      replyToId: map["replyToId"],
      replyText: map["replyText"],
      replySenderName: map["replySenderName"],
      isUploading: map["isUploading"] ?? false,
      localPath: map["localPath"],
    );
  }
}
