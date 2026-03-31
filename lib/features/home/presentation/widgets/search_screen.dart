import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:piko/features/home/presentation/widgets/search_status_view.dart';
import 'package:piko/features/home/presentation/widgets/user_search_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeCubit.isDarkMode;
    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.darkBackground
          : ColorsManager.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            homeCubit.clearSearch();
            context.pop;
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          appTranslation().get("search"),
          style: TextStylesManager.bold20.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            verticalSpace10,
            SearchBarWidget(
              controller: _searchController,
              isDark: isDark,
              onClear: () {
                _searchController.clear();
                homeCubit.clearSearch();
                setState(() {});
              },
            ),
            verticalSpace24,
            Expanded(
              child: BlocBuilder<HomeCubit, HomeStates>(
                buildWhen: (_, state) =>
                    state is SearchInitialState ||
                    state is SearchLoadingState ||
                    state is SearchSuccessState ||
                    state is SearchErrorState,
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildResultWidget(context, state, isDark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget(
    BuildContext context,
    HomeStates state,
    bool isDark,
  ) {
    if (state is SearchLoadingState) {
      return const Center(child: LoadingIndicator());
    }

    if (state is SearchSuccessState) {
      final user = state.user;
      if (user != null) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            UserSearchTile(user: user, isDark: isDark),
          ],
        );
      } else if (_searchController.text.isNotEmpty) {
        return SearchStatusView(
          icon: Icons.person_search_rounded,
          text: appTranslation().get("no_user_found"),
          isDark: isDark,
        );
      }
    }

    if (state is SearchErrorState) {
      return SearchStatusView(
        icon: Icons.error_outline_rounded,
        text: "${appTranslation().get("something_went_wrong")}: ${state.error}",
        isDark: isDark,
        color: ColorsManager.error,
      );
    }

    return SearchStatusView(
      icon: Icons.search_rounded,
      text: appTranslation().get("search_start_typing"),
      isDark: isDark,
    );
  }
}
