import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/features/home/presentation/widgets/conversation_list.dart';
import 'package:piko/features/home/presentation/widgets/empty_chats.dart';
import 'package:piko/features/home/presentation/widgets/home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    authCubit.getUserData().then((_) {
      homeCubit.setOnlineStatus(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    homeCubit.setOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      homeCubit.setOnlineStatus(true);
    } else {
      homeCubit.setOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      buildWhen: (_, state) =>
          state is AuthGetUserLoadingState ||
          state is AuthGetUserSuccessState ||
          state is AuthGetUserErrorState,
      builder: (context, state) {
        final user = authCubit.currentUserModel;
        return Scaffold(
          appBar: const HomeAppBar(),
          body: ConditionalBuilder(
            loadingState: user == null,
            loadingBuilder: (_) => const LoadingIndicator(),
            successBuilder: (_) => StreamBuilder<List<ChatModel>>(
              stream: homeCubit.getChatsStream(user!.uid),
              builder: (_, snap) {
                if (!snap.hasData) return const LoadingIndicator();
                final chats = snap.data!;
                if (chats.isEmpty) return const EmptyChats();
                return ConversationList(chats: chats);
              },
            ),
          ),
        );
      },
    );
  }
}
