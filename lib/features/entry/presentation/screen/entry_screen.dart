import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routeUser();
    });
  }

  Future<void> _routeUser() async {
    final onBoardingSeen = CacheHelper.getData(key: 'onBoarding') ?? false;

    if (!onBoardingSeen) {
      context.pushReplacement<Object>(Routes.onBoarding);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.pushReplacement<Object>(Routes.login);
      return;
    }

    final isCompleted = CacheHelper.getData(key: 'isProfileCompleted') ?? false;
    if (!isCompleted) {
      context.pushReplacement<Object>(Routes.completeProfile);
      return;
    }

    context.pushReplacement<Object>(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
