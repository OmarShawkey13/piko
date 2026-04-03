import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/network/service/notification_service.dart';
import 'package:piko/core/network/local/sqflite_helper.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:rxdart/rxdart.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(ChatInitialState());

  static ChatCubit get(BuildContext context) => BlocProvider.of(context);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Selection Mode
  bool isSelectionMode = false;
  final List<MessageModel> selectedMessages = [];

  // Search Mode
  bool isSearchActive = false;
  String searchQuery = "";
  List<String> searchResultIds = [];
  int currentSearchIndex = -1;
  List<MessageModel> currentMessages = [];

  void updateCurrentMessages(List<MessageModel> messages) {
    currentMessages = messages;
  }

  void toggleSearch() {
    isSearchActive = !isSearchActive;
    if (!isSearchActive) {
      searchQuery = "";
      searchResultIds = [];
      currentSearchIndex = -1;
    }
    emit(ChatSearchToggleState(isSearchActive));
  }

  void searchMessages(String query) {
    searchQuery = query.trim().toLowerCase();
    if (searchQuery.isEmpty) {
      searchResultIds = [];
      currentSearchIndex = -1;
      emit(
        ChatSearchResultsUpdatedState(
          resultIds: [],
          currentIndex: -1,
          query: "",
        ),
      );
      return;
    }

    searchResultIds = currentMessages
        .where((msg) => msg.text.toLowerCase().contains(searchQuery))
        .map((msg) => msg.id)
        .toList(); // No need to reverse here if we want index 0 to be the "first" found in chronological order or vice versa.
    // However, the ListView is reversed: true, meaning the bottom is index 0 in the list but last in the data.
    // currentMessages is in chronological order (descending: false in stream).
    // So currentMessages[0] is the OLDEST message.
    // In searchResultIds, we want 0 to be the LATEST message found if we want to start from the bottom.
    // So let's reverse searchResultIds.
    searchResultIds = searchResultIds.reversed.toList();

    if (searchResultIds.isNotEmpty) {
      currentSearchIndex = 0;
    } else {
      currentSearchIndex = -1;
    }

    emit(
      ChatSearchResultsUpdatedState(
        resultIds: searchResultIds,
        currentIndex: currentSearchIndex,
        query: searchQuery,
      ),
    );
  }

  void nextSearchResult() {
    if (searchResultIds.isEmpty) return;
    currentSearchIndex = (currentSearchIndex + 1) % searchResultIds.length;
    emit(
      ChatSearchResultsUpdatedState(
        resultIds: searchResultIds,
        currentIndex: currentSearchIndex,
        query: searchQuery,
      ),
    );
  }

  void previousSearchResult() {
    if (searchResultIds.isEmpty) return;
    currentSearchIndex =
        (currentSearchIndex - 1 + searchResultIds.length) %
        searchResultIds.length;
    emit(
      ChatSearchResultsUpdatedState(
        resultIds: searchResultIds,
        currentIndex: currentSearchIndex,
        query: searchQuery,
      ),
    );
  }

  void toggleSelectionMode({MessageModel? initialMessage}) {
    isSelectionMode = !isSelectionMode;
    selectedMessages.clear();
    if (isSelectionMode && initialMessage != null) {
      selectedMessages.add(initialMessage);
    }
    emit(ChatSelectionModeChangedState());
  }

  void toggleMessageSelection(MessageModel message) {
    if (selectedMessages.any((m) => m.id == message.id)) {
      selectedMessages.removeWhere((m) => m.id == message.id);
      if (selectedMessages.isEmpty) isSelectionMode = false;
    } else {
      selectedMessages.add(message);
    }
    emit(ChatSelectionModeChangedState());
  }

  void clearSelection() {
    isSelectionMode = false;
    selectedMessages.clear();
    emit(ChatSelectionModeChangedState());
  }

  // Chat Background
  Uint8List? chatBackgroundBytes;

  Future<void> pickChatBackground() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final bytes = await File(file.path).readAsBytes();
      chatBackgroundBytes = bytes;

      await CacheHelper.saveData(
        key: "chatBackground",
        value: base64Encode(bytes),
      );
      emit(ChatBackgroundChangedState());
    } catch (e) {
      debugPrint("Chat background error: $e");
    }
  }

  void loadChatBackground() {
    final base64 = CacheHelper.getData(key: "chatBackground");
    if (base64 != null) {
      chatBackgroundBytes = base64Decode(base64);
      emit(ChatBackgroundChangedState());
    }
  }

  // Reply
  MessageModel? replyingMessage;

  void setReplyingMessage(MessageModel? message) {
    replyingMessage = message;
    emit(ChatReplyingMessageChangedState());
  }

  // Messaging
  Future<void> sendMessage({
    required String myId,
    required String otherId,
    required String text,
    required UserModel myUser,
    required UserModel otherUser,
    List<Map<String, String>>? mediaData,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && (mediaData == null || mediaData.isEmpty)) return;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (mediaData != null && mediaData.isNotEmpty) {
        for (var media in mediaData) {
          await _sendSingleMessage(
            myId: myId,
            otherId: otherId,
            text: "",
            myUser: myUser,
            otherUser: otherUser,
            imageUrl: media['url'],
            fileSize: media['size'],
            timestamp: timestamp,
            isUploading: media['isUploading'] == 'true',
            localPath: media['localPath'],
          );
        }
      }

      if (trimmedText.isNotEmpty) {
        await _sendSingleMessage(
          myId: myId,
          otherId: otherId,
          text: trimmedText,
          myUser: myUser,
          otherUser: otherUser,
          timestamp: timestamp + 1,
          replyToId: replyingMessage?.id,
          replyText: replyingMessage?.text.isEmpty == true
              ? "Attachment"
              : replyingMessage?.text,
          replySenderName: replyingMessage?.senderId == myId
              ? "You"
              : otherUser.displayName,
        );
      }

      setReplyingMessage(null);
      emit(ChatSendSuccessState());
    } catch (e) {
      emit(ChatSendErrorState(e.toString()));
    }
  }

  Future<void> _sendSingleMessage({
    required String myId,
    required String otherId,
    required String text,
    required UserModel myUser,
    required UserModel otherUser,
    String? imageUrl,
    String? fileSize,
    required int timestamp,
    String? replyToId,
    String? replyText,
    String? replySenderName,
    bool isUploading = false,
    String? localPath,
  }) async {
    final messageId = _firestore.collection("users").doc().id;
    final messageData = {
      "senderId": myId,
      "receiverId": otherId,
      "text": text,
      "timestamp": timestamp,
      "seen": false,
      "imageUrl": imageUrl,
      "fileSize": fileSize,
      "replyToId": replyToId,
      "replyText": replyText,
      "replySenderName": replySenderName,
      "isUploading": isUploading,
      "localPath": localPath,
    };

    final myChatRef = _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId);

    await myChatRef.collection("messages").doc(messageId).set(messageData);

    await myChatRef.set({
      "uid": otherId,
      "displayName": otherUser.displayName,
      "username": otherUser.username,
      "photoUrl": otherUser.photoUrl,
      "lastMessage": text.isEmpty ? "Attachment" : text,
      "timestamp": timestamp,
      "imageUrl": imageUrl,
      "draft": "",
    }, SetOptions(merge: true));

    if (!isUploading) {
      await _finalizeMessageForOther(
        messageId: messageId,
        messageData: messageData,
        myId: myId,
        otherId: otherId,
        myUser: myUser,
        otherUser: otherUser,
      );
    }
  }

  Future<void> _finalizeMessageForOther({
    required String messageId,
    required Map<String, dynamic> messageData,
    required String myId,
    required String otherId,
    required UserModel myUser,
    required UserModel otherUser,
  }) async {
    final otherChatRef = _firestore
        .collection("users")
        .doc(otherId)
        .collection("chats")
        .doc(myId);
    final batch = _firestore.batch();

    final finalData = Map<String, dynamic>.from(messageData)
      ..["isUploading"] = false
      ..["localPath"] = null;

    batch.set(otherChatRef.collection("messages").doc(messageId), finalData);
    batch.set(otherChatRef, {
      "uid": myId,
      "displayName": myUser.displayName,
      "username": myUser.username,
      "photoUrl": myUser.photoUrl,
      "lastMessage": finalData["text"].isEmpty
          ? "Attachment"
          : finalData["text"],
      "imageUrl": finalData["imageUrl"],
      "timestamp": finalData["timestamp"],
      "unreadCount": FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();

    if (otherUser.uid.isNotEmpty) {
      unawaited(
        NotificationService.sendOneSignalMessage(
          externalId: otherUser.uid,
          title: myUser.displayName,
          body: finalData["text"].isEmpty
              ? "Sent an attachment"
              : finalData["text"],
        ),
      );
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String myId, String otherId) {
    // 1. Get cached messages from SQLite
    final localStream = Stream.fromFuture(
      SqfliteHelper.getMessages(myId, otherId),
    );

    // 2. Get real-time messages from Firestore
    final remoteStream = _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snap) {
          final messages = snap.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
              .toList();

          // 3. Cache messages as they arrive from Firestore
          for (var msg in messages) {
            SqfliteHelper.insertMessage(msg);
          }
          return messages;
        });

    // Merge both streams: show local immediately, then update with remote
    return MergeStream([localStream, remoteStream]);
  }

  Future<void> markAllMessagesAsSeen(
    String myId,
    String otherId,
    String msgId,
  ) async {
    try {
      final batch = _firestore.batch();
      final myMsgRef = _firestore
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId)
          .collection("messages")
          .doc(msgId);
      final otherMsgRef = _firestore
          .collection("users")
          .doc(otherId)
          .collection("chats")
          .doc(myId)
          .collection("messages")
          .doc(msgId);

      batch.update(myMsgRef, {"seen": true});

      final otherDoc = await otherMsgRef.get();
      if (otherDoc.exists) batch.update(otherMsgRef, {"seen": true});

      batch.update(
        _firestore
            .collection("users")
            .doc(myId)
            .collection("chats")
            .doc(otherId),
        {"unreadCount": 0},
      );
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking messages as seen: $e");
    }
  }

  Future<void> deleteMessage({
    required String myId,
    required String otherId,
    required String messageId,
    required bool deleteForEveryone,
  }) async {
    try {
      await _handleSingleDeletion(
        ownerId: myId,
        otherId: otherId,
        messageId: messageId,
      );
      if (deleteForEveryone) {
        await _handleSingleDeletion(
          ownerId: otherId,
          otherId: myId,
          messageId: messageId,
        );
      }
      emit(ChatDeleteMessageSuccessState());
    } catch (e) {
      emit(ChatDeleteMessageErrorState(e.toString()));
    }
  }

  Future<void> deleteSelectedMessages({
    required String myId,
    required String otherId,
    required bool deleteForEveryone,
  }) async {
    try {
      final ids = selectedMessages.map((m) => m.id).toList();
      clearSelection();
      await Future.wait(
        ids.map(
          (id) => deleteMessage(
            myId: myId,
            otherId: otherId,
            messageId: id,
            deleteForEveryone: deleteForEveryone,
          ),
        ),
      );
    } catch (e) {
      emit(ChatDeleteMessageErrorState(e.toString()));
    }
  }

  Future<void> _handleSingleDeletion({
    required String ownerId,
    required String otherId,
    required String messageId,
  }) async {
    final chatRef = _firestore
        .collection("users")
        .doc(ownerId)
        .collection("chats")
        .doc(otherId);
    final msgDoc = await chatRef.collection("messages").doc(messageId).get();

    if (msgDoc.exists) {
      final data = msgDoc.data()!;
      if (data['seen'] == false && data['senderId'] != ownerId) {
        await chatRef.update({'unreadCount': FieldValue.increment(-1)});
      }
      await chatRef.collection("messages").doc(messageId).delete();
    }

    final lastMsgs = await chatRef
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (lastMsgs.docs.isEmpty) {
      await chatRef.delete();
    } else {
      final newLastMsg = lastMsgs.docs.first.data();
      await chatRef.update({
        'lastMessage': (newLastMsg["text"] as String?)?.isEmpty == true
            ? "Attachment"
            : newLastMsg["text"],
        'timestamp': newLastMsg["timestamp"],
        'imageUrl': newLastMsg["imageUrl"],
      });
    }
  }

  Stream<bool> getTypingStatus(String myId, String otherId) {
    return _firestore
        .collection("users")
        .doc(otherId)
        .collection("chats")
        .doc(myId)
        .snapshots()
        .map((doc) => doc.data()?["isTyping"] ?? false);
  }

  Future<void> setTypingStatus({
    required String myId,
    required String otherId,
    required bool isTyping,
  }) async {
    await _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .set({"isTyping": isTyping}, SetOptions(merge: true));
  }

  Future<List<XFile>> pickMediaFiles({
    required ImageSource source,
    bool isVideo = false,
  }) async {
    try {
      if (source == ImageSource.camera) {
        final file = isVideo
            ? await _picker.pickVideo(source: ImageSource.camera)
            : await _picker.pickImage(source: ImageSource.camera);
        return file != null ? [file] : [];
      }
      return await _picker.pickMultipleMedia();
    } catch (e) {
      debugPrint("Pick media error: $e");
      return [];
    }
  }

  Future<void> uploadAndSend({
    required List<XFile> files,
    required String myId,
    required String otherId,
    required UserModel myUser,
    required UserModel otherUser,
  }) async {
    for (var file in files) {
      final size = _formatBytes(await file.length(), 1);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final messageId = _firestore.collection("users").doc().id;
      final myChatRef = _firestore
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId);

      await myChatRef.collection("messages").doc(messageId).set({
        "senderId": myId,
        "receiverId": otherId,
        "text": "",
        "timestamp": timestamp,
        "seen": false,
        "imageUrl": null,
        "fileSize": size,
        "isUploading": true,
        "localPath": file.path,
      });

      await myChatRef.set({
        "uid": otherId,
        "lastMessage": "Attachment",
        "timestamp": timestamp,
      }, SetOptions(merge: true));

      unawaited(
        _performBackgroundUpload(
          file: File(file.path),
          messageId: messageId,
          myId: myId,
          otherId: otherId,
          myUser: myUser,
          otherUser: otherUser,
          size: size,
          timestamp: timestamp,
        ),
      );
    }
  }

  Future<void> _performBackgroundUpload({
    required File file,
    required String messageId,
    required String myId,
    required String otherId,
    required UserModel myUser,
    required UserModel otherUser,
    required String size,
    required int timestamp,
  }) async {
    try {
      final url = await _uploadToCloudinary(file);
      final messageData = {
        "senderId": myId,
        "receiverId": otherId,
        "text": "",
        "timestamp": timestamp,
        "seen": false,
        "imageUrl": url,
        "fileSize": size,
        "isUploading": false,
        "localPath": null,
      };

      await _firestore
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId)
          .collection("messages")
          .doc(messageId)
          .set(messageData);
      await _finalizeMessageForOther(
        messageId: messageId,
        messageData: messageData,
        myId: myId,
        otherId: otherId,
        myUser: myUser,
        otherUser: otherUser,
      );
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<String> _uploadToCloudinary(File file) async {
    const cloudName = "dvv07qlxn";
    const uploadPreset = "userProfile";
    final isVideo =
        file.path.toLowerCase().endsWith(".mp4") ||
        file.path.toLowerCase().endsWith(".mov");
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? "video" : "image"}/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final result = await response.stream.bytesToString();
    return json.decode(result)["secure_url"];
  }

  String? detectedUrl;
  Timer? _urlDebounceTimer;
  static final _urlRegex = RegExp(
    r'((https?:\/\/)|(www\.))[^\s]+',
    caseSensitive: false,
  );

  void detectUrl(String text) {
    _urlDebounceTimer?.cancel();
    _urlDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (text.trim().isEmpty) {
        if (detectedUrl != null) {
          detectedUrl = null;
          emit(ChatUrlDetectedState(null));
        }
        return;
      }
      var rawUrl = _urlRegex.firstMatch(text)?.group(0);
      if (rawUrl != null) {
        rawUrl = rawUrl.replaceAll(RegExp(r'[.,!?]+$'), '');
        if (rawUrl.toLowerCase().startsWith('www.')) rawUrl = 'https://$rawUrl';
      }
      if (rawUrl != detectedUrl) {
        detectedUrl = rawUrl;
        emit(ChatUrlDetectedState(rawUrl));
      }
    });
  }

  void clearDetectedUrl() {
    detectedUrl = null;
    emit(ChatUrlDetectedState(null));
  }

  Timer? _draftTimer;

  void updateDraft(String myId, String otherId, String text) {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), () {
      _firestore
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId)
          .set({
            "draft": text,
            "draftUpdatedAt": DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));
    });
  }

  Future<void> loadDraft({
    required String myId,
    required String otherId,
    required TextEditingController messageController,
  }) async {
    final doc = await _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .get();
    if (doc.exists && doc.data()?["draft"] != null) {
      messageController.text = doc.data()!["draft"];
    }
  }

  @override
  Future<void> close() {
    _urlDebounceTimer?.cancel();
    _draftTimer?.cancel();
    return super.close();
  }
}
