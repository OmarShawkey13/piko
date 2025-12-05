import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/network/service/notification_service.dart';
import 'package:piko/core/network/user_repository.dart';
import 'package:piko/core/utils/constants/translations.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/main.dart';

HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void changeTheme({bool? fromShared}) {
    _isDarkMode = fromShared ?? !_isDarkMode;
    CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
    emit(HomeChangeThemeState());
  }

  bool _isArabicLang = false;
  TranslationModel? _translationModel;

  // Getters فقط (لا نسمح لأي كود خارجي يعدل القيمة)
  bool get isArabicLang => _isArabicLang;
  TranslationModel? get translationModel => _translationModel;

  /// تغيير اللغة — الدالة الرسمية الوحيدة
  Future<void> changeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      if (_isArabicLang == isArabic && _translationModel != null) {
        emit(HomeLanguageUpdatedState());
        return;
      }
      emit(HomeLanguageLoadingState());
      final model = TranslationModel.fromJson(json.decode(translations));
      _isArabicLang = isArabic;
      _translationModel = model;
      emit(HomeLanguageUpdatedState());
    } catch (e) {
      emit(HomeLanguageErrorState(e.toString()));
    }
  }

  Future<void> initializeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      _isArabicLang = isArabic;
      _translationModel = TranslationModel.fromJson(json.decode(translations));
      emit(HomeLanguageLoadedState());
    } catch (e) {
      emit(HomeLanguageErrorState(e.toString()));
    }
  }

  //login
  bool _isShowPassword = false;

  bool get isShowPassword => _isShowPassword;

  void togglePasswordVisibility() {
    _isShowPassword = !_isShowPassword;
    emit(HomeShowPasswordUpdatedState());
  }

  // (افترض وجود تعريفات HomeState و UserModel)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserRepository userRepo = UserRepository();

  Future<void> login() async {
    emit(HomeLoginLoadingState());
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final User? user = await _signInUser(email, password);
      if (user != null) {
        final refreshed = await _reloadUser(user);
        await OneSignal.login(refreshed.uid);
        CacheHelper.saveData(key: 'isProfileCompleted', value: true);
        emit(HomeLoginSuccessState(refreshed, false));
        return;
      }
      final newUser = await _registerUser(email, password);
      await _createUserInFirestore(newUser);
      await OneSignal.login(newUser.uid);
      emit(HomeLoginSuccessState(newUser, true));
    } on FirebaseAuthException catch (e) {
      emit(HomeLoginErrorState(e.message ?? "Authentication failed."));
    } catch (e) {
      emit(HomeLoginErrorState(e.toString()));
    }
  }

  /// ------------------ HELPERS ------------------

  Future<User?> _signInUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return null;
      rethrow;
    }
  }

  Future<User> _registerUser(String email, String password) async {
    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user!;
  }

  Future<User> _reloadUser(User user) async {
    await user.reload();
    return FirebaseAuth.instance.currentUser!;
  }

  Future<void> _createUserInFirestore(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: "",
      username: "",
      photoUrl: "",
      bio: "",
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );
    await userRepo.createUser(userModel);
  }

  //complete profile
  final TextEditingController displayNameController = TextEditingController();
  String? profileImageUrl;
  bool isUploadingImage = false;

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      emit(HomeUploadImageLoadingState());
      isUploadingImage = true;
      final uploadedUrl = await _uploadToCloudinary(File(image.path));
      profileImageUrl = uploadedUrl;
      isUploadingImage = false;
      emit(HomeUploadImageSuccessState(uploadedUrl));
    } catch (e) {
      isUploadingImage = false;
      emit(HomeUploadImageErrorState(e.toString()));
    }
  }

  Future<String> _uploadToCloudinary(File file) async {
    const cloudName = "dvv07qlxn";
    const uploadPreset = "userProfile";
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));
    final response = await request.send();
    final result = await response.stream.bytesToString();
    final jsonData = json.decode(result);
    return jsonData["secure_url"];
  }

  Future<void> saveProfile() async {
    final displayName = displayNameController.text.trim();
    if (displayName.isEmpty) {
      emit(HomeCompleteProfileErrorState("Display name is required"));
      return;
    }
    emit(HomeCompleteProfileLoadingState());
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await userRepo.updateUser(uid, {
        "displayName": displayName,
        "photoUrl": profileImageUrl ?? "",
        "bio": "Hi there! I'm using Piko.",
      });
      CacheHelper.saveData(key: 'isProfileCompleted', value: true);
      emit(HomeCompleteProfileSuccessState());
    } catch (e) {
      emit(HomeCompleteProfileErrorState(e.toString()));
    }
  }

  UserModel? currentUserModel;

  Future<void> cacheUser(UserModel? model) async {
    final json = jsonEncode(model!.toMap());
    await CacheHelper.saveData(key: 'userModel', value: json);
  }

  UserModel? getCachedUser() {
    final json = CacheHelper.getData(key: 'userModel');
    if (json == null) return null;
    return UserModel.fromMap(
      jsonDecode(json),
      FirebaseAuth.instance.currentUser!.uid,
    );
  }

  Future<void> getUserData() async {
    final cached = getCachedUser();
    if (cached != null) {
      currentUserModel = cached;
      emit(HomeGetUserSuccessState());
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final fresh = await userRepo.getUser(uid);
      currentUserModel = fresh;
      await cacheUser(fresh);
      emit(HomeGetUserSuccessState());
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (cached == null) {
        emit(HomeGetUserErrorState(e.toString()));
      }
    }
  }

  Timer? _debounce;

  void searchUsername(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      if (username.isEmpty) {
        emit(SearchInitialState());
        return;
      }
      emit(SearchLoadingState());
      try {
        final user = await searchByUsername(username);
        emit(SearchSuccessState(user));
      } catch (e) {
        emit(SearchErrorState(e.toString()));
      }
    });
  }

  Future<UserModel?> searchByUsername(String username) async {
    final query = username.trim().toLowerCase();
    if (query.isEmpty) return null;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: query)
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    final doc = result.docs.first;
    if (doc.id == currentUid) return null;
    return UserModel.fromMap(doc.data(), doc.id);
  }

  //chat
  Uint8List? chatBackgroundBytes;

  Future<void> pickChatBackground() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      // BYTES مرة واحدة
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
    }
  }

  Future<void> sendMessage({
    required String myId,
    required String otherId,
    required String text,
    required UserModel myUser,
    required UserModel otherUser,
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty && (imageUrl == null || imageUrl.isEmpty)) return;

    try {
      final time = DateTime.now().millisecondsSinceEpoch;

      final msg = {
        "senderId": myId,
        "receiverId": otherId,
        "text": text,
        "timestamp": time,
        "seen": false,
        "imageUrl": imageUrl,
      };

      final myChats = FirebaseFirestore.instance
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId);

      final otherChats = FirebaseFirestore.instance
          .collection("users")
          .doc(otherId)
          .collection("chats")
          .doc(myId);

      final batch = FirebaseFirestore.instance.batch();

      /// Message refs
      final myMsgRef = myChats.collection("messages").doc();
      final otherMsgRef = otherChats.collection("messages").doc(myMsgRef.id);

      batch.set(myMsgRef, msg);
      batch.set(otherMsgRef, msg);

      /// Update MY chat preview
      batch.set(
        myChats,
        {
          "uid": otherId,
          "displayName": otherUser.displayName,
          "username": otherUser.username,
          "photoUrl": otherUser.photoUrl,
          "lastMessage": text,
          "timestamp": time,
          "imageUrl": imageUrl,
        },
        SetOptions(merge: true),
      );

      /// Update OTHER chat preview + increase unreadCount
      batch.set(
        otherChats,
        {
          "uid": myId,
          "displayName": myUser.displayName,
          "username": myUser.username,
          "photoUrl": myUser.photoUrl,
          "lastMessage": text.isEmpty ? "Photo" : text, // لو صورة بس
          "imageUrl": imageUrl, // ← مهم جداً
          "timestamp": time,
          "unreadCount": FieldValue.increment(1), // ✔ مهم جداً
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      FirebaseFirestore.instance
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId)
          .update({"draft": ""});

      /// Send notification (optional)
      if (otherUser.uid.isNotEmpty) {
        await NotificationService.sendOneSignalMessage(
          externalId: otherUser.uid,
          title: myUser.displayName,
          body: text,
        );
      }
      emit(ChatSendSuccessState());
    } catch (e) {
      emit(ChatSendErrorState(e.toString()));
    }
  }

  Stream<bool> getTypingStatus(String myId, String otherId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(otherId)
        .collection("chats")
        .doc(myId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final data = doc.data();
          return data?["isTyping"] ?? false;
        });
  }

  Future<void> markAllMessagesAsSeen(
    String myId,
    String otherId,
    String msgId,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    /// Update my messages copy
    final myMsgRef = FirebaseFirestore.instance
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .collection("messages")
        .doc(msgId);

    batch.update(myMsgRef, {"seen": true});

    /// Update other user's messages copy
    final otherMsgRef = FirebaseFirestore.instance
        .collection("users")
        .doc(otherId)
        .collection("chats")
        .doc(myId)
        .collection("messages")
        .doc(msgId);

    batch.update(otherMsgRef, {"seen": true});

    /// Reset unreadCount FOR MY preview only
    final myChatPreviewRef = FirebaseFirestore.instance
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId);

    batch.update(myChatPreviewRef, {"unreadCount": 0});

    await batch.commit();
  }

  Future<void> setTypingStatus({
    required String myId,
    required String otherId,
    required bool isTyping,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .set(
          {"isTyping": isTyping},
          SetOptions(merge: true),
        );
  }

  String? uploadedImageUrl;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    emit(ChatUploadImageLoadingState());

    try {
      final url = await _uploadToCloudinary(File(file.path));

      uploadedImageUrl = url;

      emit(ChatUploadImageSuccessState(url));
    } catch (e) {
      emit(ChatUploadImageErrorState(e.toString()));
    }
  }

  String? currentDraft;
  Timer? _draftTimer;

  void updateDraft(String myId, String otherId, String text) {
    currentDraft = text;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 500), () {
      FirebaseFirestore.instance
          .collection("users")
          .doc(myId)
          .collection("chats")
          .doc(otherId)
          .set(
            {
              "draft": text,
              "draftUpdatedAt": DateTime.now().millisecondsSinceEpoch,
            },
            SetOptions(merge: true),
          );
    });
  }

  Future<void> loadDraft({
    required String otherId,
    required TextEditingController messageController,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserModel!.uid)
        .collection("chats")
        .doc(otherId)
        .get();

    if (doc.exists && doc.data()?["draft"] != null) {
      final draft = doc.data()?["draft"];
      messageController.text = draft;
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      final uid = currentUserModel?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "online": isOnline,
        "lastActive": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Online error: $e");
    }
  }

  /// STREAM للرسائل (كما هو لأنه ممتاز)
  Stream<List<MessageModel>> getMessagesStream(String myId, String otherId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(myId)
        .collection("chats")
        .doc(otherId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (e) => MessageModel.fromMap(e.id, e.data()),
              )
              .toList(),
        );
  }

  Stream<List<ChatModel>> getChatsStream(String myId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(myId)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots()
        // 2. تحويل الـ Stream إلى Stream<List<ChatModel>> باستخدام asyncMap
        .asyncMap((snap) async {
          final List<ChatModel> chatList = [];

          // 3. التكرار على كل مستند محادثة تم جلبه
          for (var doc in snap.docs) {
            final chatData = doc.data();
            final otherId = doc.id; // UID بتاع الشخص التاني هو ID بتاع المستند

            // 4. إجراء استعلام لحساب عدد الرسائل غير المقروءة
            final unreadSnapshot = await FirebaseFirestore.instance
                .collection("users")
                .doc(myId)
                .collection("chats")
                .doc(otherId)
                .collection("messages")
                .where(
                  "receiverId",
                  isEqualTo: myId,
                ) // الرسائل المُرسلة إليّ فقط
                .where("seen", isEqualTo: false) // الرسائل غير المقروءة
                .get();

            final unreadCount = unreadSnapshot.docs.length;

            // 5. إنشاء نموذج ChatModel وإضافته للقائمة
            // نستخدم doc.id كـ UID للشخص الآخر
            chatList.add(
              ChatModel.fromMap(
                chatData,
                otherId,
                unreadCount,
              ),
            );
          }
          return chatList;
        });
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    emit(EditProfileLoadingState());
    try {
      final uid = currentUserModel!.uid;
      final Map<String, dynamic> data = {};
      if (displayName != null) data['displayName'] = displayName;
      if (username != null) data['username'] = username.toLowerCase();
      if (bio != null) data['bio'] = bio;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      await userRepo.updateUser(uid, data);
      final updatedUser = currentUserModel!.copyWith(
        displayName: displayName,
        username: username?.toLowerCase(),
        bio: bio,
        photoUrl: photoUrl,
      );
      currentUserModel = updatedUser;
      await cacheUser(updatedUser);
      emit(EditProfileSuccessState());
    } catch (e) {
      emit(EditProfileErrorState(e.toString()));
    }
  }

  Future<String> uploadProfileImage(File file) async {
    final uploadedUrl = await _uploadToCloudinary(file);
    return uploadedUrl;
  }
}
