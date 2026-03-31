import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/main.dart';

HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _debounce;

  void searchUsername(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (username.trim().isEmpty) {
      emit(SearchInitialState());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () async {
      emit(SearchLoadingState());
      try {
        final user = await searchByUsername(username);
        emit(SearchSuccessState(user));
      } catch (e) {
        emit(SearchErrorState(e.toString()));
      }
    });
  }

  void clearSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    emit(SearchInitialState());
  }

  Future<UserModel?> searchByUsername(String username) async {
    final query = username.trim().toLowerCase();
    if (query.isEmpty) return null;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return null;

    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: query)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    final doc = result.docs.first;
    if (doc.id == currentUid) return null;

    return UserModel.fromMap(doc.data(), doc.id);
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      final uid = authCubit.currentUserModel?.uid;
      if (uid == null) return;

      await _firestore.collection("users").doc(uid).set({
        "online": isOnline,
        "lastActive": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Online error: $e");
    }
  }

  Stream<List<ChatModel>> getChatsStream(String myId) {
    return _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final List<ChatModel> chatList = [];

          for (var doc in snap.docs) {
            final chatData = doc.data();
            final otherId = doc.id;

            final unreadSnapshot = await _firestore
                .collection("users")
                .doc(myId)
                .collection("chats")
                .doc(otherId)
                .collection("messages")
                .where("receiverId", isEqualTo: myId)
                .where("seen", isEqualTo: false)
                .get();

            chatList.add(
              ChatModel.fromMap(
                chatData,
                otherId,
                unreadSnapshot.docs.length,
              ),
            );
          }
          return chatList;
        });
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
}
