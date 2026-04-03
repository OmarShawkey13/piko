import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/network/local/sqflite_helper.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/main.dart';
import 'package:rxdart/rxdart.dart';

HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _debounce;

  double scale = 1.0;
  String? activeId;

  void changeScale(String id, double value) {
    activeId = id;
    scale = value;
    emit(HomeChangeScaleState());
  }

  void searchUsername(String username, String currentUid) {
    _debounce?.cancel();

    final query = username.trim().toLowerCase();
    if (query.isEmpty) {
      emit(SearchInitialState());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      emit(SearchLoadingState());
      try {
        final result = await _firestore
            .collection('users')
            .where('username', isEqualTo: query)
            .limit(1)
            .get();

        if (result.docs.isEmpty || result.docs.first.id == currentUid) {
          emit(SearchSuccessState(null));
        } else {
          final doc = result.docs.first;
          emit(SearchSuccessState(UserModel.fromMap(doc.data(), doc.id)));
        }
      } catch (e) {
        emit(SearchErrorState(e.toString()));
      }
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(SearchInitialState());
  }

  Future<void> setOnlineStatus(String? uid, bool isOnline) async {
    if (uid == null) return;
    try {
      await _firestore.collection("users").doc(uid).set({
        "online": isOnline,
        "lastActive": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Online status error: $e");
    }
  }

  Stream<List<ChatModel>> getChatsStream(String myId) {
    // 1. Get cached chats from SQLite
    final localStream = Stream.fromFuture(SqfliteHelper.getChats());

    // 2. Get real-time chats from Firestore
    final remoteStream = _firestore
        .collection("users")
        .doc(myId)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snap) {
          final chats = snap.docs.map((doc) {
            final data = doc.data();
            final chat = ChatModel.fromMap(
              data,
              doc.id,
              data['unreadCount'] ?? 0,
            );
            // 3. Cache each chat as it arrives
            SqfliteHelper.insertChat(chat);
            return chat;
          }).toList();
          return chats;
        });

    // Merge streams: show local first, then update with remote
    return MergeStream([localStream, remoteStream]);
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

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
