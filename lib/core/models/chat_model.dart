class ChatModel {
  final String uid; // id بتاع الشخص التاني
  final String displayName;
  final String username;
  final String photoUrl;
  final String lastMessage;
  final int timestamp;
  final int unreadCount;
  final String draft;
  //imageUrl
  final String? imageUrl;

  ChatModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.draft = "",
    this.imageUrl,
  });

  factory ChatModel.fromMap(
    Map<String, dynamic> map,
    String uid,
    int unreadCount,
  ) {
    return ChatModel(
      uid: uid,
      displayName: map["displayName"] ?? "",
      username: map["username"] ?? "",
      photoUrl: map["photoUrl"] ?? "",
      lastMessage: map["lastMessage"] ?? "",
      timestamp: map["timestamp"] ?? 0,
      unreadCount: unreadCount,
      draft: map["draft"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // UID هنا اختياري، لكن تمت إضافته للتماسك
      "uid": uid,
      "displayName": displayName,
      "username": username,
      "photoUrl": photoUrl,
      "lastMessage": lastMessage,
      "timestamp": timestamp,
      "unreadCount": unreadCount,
      "draft": draft,
      "imageUrl": imageUrl,
    };
  }
}
