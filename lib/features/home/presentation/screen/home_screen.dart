import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/constants/primary/primary_text_form_field.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/auth/auth_state.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/cubit/theme/theme_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
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
      final myId = authCubit.currentUserModel?.uid;
      if (myId != null) homeCubit.setOnlineStatus(myId, true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final myId = authCubit.currentUserModel?.uid;
    if (myId != null) homeCubit.setOnlineStatus(myId, false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final myId = authCubit.currentUserModel?.uid;
    if (myId == null) return;

    if (state == AppLifecycleState.resumed) {
      homeCubit.setOnlineStatus(myId, true);
    } else {
      homeCubit.setOnlineStatus(myId, false);
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
            successBuilder: (_) => BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: PrimaryTextFormField(
                        readOnly: true,
                        onTap: () => context.push<Object>(Routes.search),
                        hintText: appTranslation().get('search_hint'),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: ColorsManager.primary,
                          size: 22,
                        ),
                        filled: false,
                      ),
                    ),
                    verticalSpace8,
                    Expanded(
                      child: StreamBuilder<List<ChatModel>>(
                        stream: homeCubit.getChatsStream(user!.uid),
                        builder: (_, snap) {
                          return ConditionalBuilder(
                            loadingState: !snap.hasData,
                            emptyState: snap.hasData && snap.data!.isEmpty,
                            emptyBuilder: (_) => const EmptyChats(),
                            successBuilder: (_) =>
                                ConversationList(chats: snap.data!),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
