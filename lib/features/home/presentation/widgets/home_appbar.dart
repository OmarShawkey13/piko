import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeChangeThemeState ||
          state is HomeLanguageUpdatedState ||
          state is HomeLanguageLoadedState,
      builder: (context, state) {
        return AppBar(
          title: Text(appTranslation().get("app_name")),
          actions: [
            IconButton(
              onPressed: () {
                context.push<Object>(Routes.search);
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                context.push<Object>(Routes.settings);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
