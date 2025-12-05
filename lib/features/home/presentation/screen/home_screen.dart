import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/features/home/presentation/widgets/chats_list.dart';
import 'package:piko/features/home/presentation/widgets/empty_chats.dart';
import 'package:piko/features/home/presentation/widgets/home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // ✔ مهم جداً

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✔ تسجيل observer
    homeCubit.getUserData().then((_) {
      homeCubit.setOnlineStatus(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✔ إزالة observer
    homeCubit.setOnlineStatus(false); // ✔ خروج المستخدم عند غلق الشاشة
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// ✔ Online / Offline Management
    if (state == AppLifecycleState.resumed) {
      homeCubit.setOnlineStatus(true);
    } else {
      homeCubit.setOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeGetUserLoadingState ||
          state is HomeGetUserSuccessState ||
          state is HomeGetUserErrorState ||
          state is HomeChangeThemeState ||
          state is HomeLanguageUpdatedState,
      builder: (context, state) {
        final user = homeCubit.currentUserModel;
        return Scaffold(
          appBar: const HomeAppBar(),
          body: user == null
              ? const LoadingIndicator()
              : StreamBuilder<List<ChatModel>>(
                  stream: homeCubit.getChatsStream(user.uid),
                  builder: (_, snap) {
                    if (!snap.hasData) return const LoadingIndicator();
                    final chats = snap.data!;
                    if (chats.isEmpty) return const EmptyChats();
                    return ChatsList(chats: chats);
                  },
                ),
        );
      },
    );
  }
}
