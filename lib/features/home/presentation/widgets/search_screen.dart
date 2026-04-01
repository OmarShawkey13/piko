import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/primary/conditional_builder.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/primary/primary_status_view.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_state.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:piko/features/home/presentation/widgets/search_bar_widget.dart';
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
      appBar: PrimaryAppBar(
        title: appTranslation().get("search"),
        leading: IconButton(
          onPressed: () {
            homeCubit.clearSearch();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorsManager.textPrimary,
            size: 20,
          ),
        ),
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
                    child: ConditionalBuilder(
                      loadingState: state is SearchLoadingState,
                      errorState: state is SearchErrorState,
                      errorBuilder: (context) => PrimaryStatusView(
                        icon: Icons.error_outline_rounded,
                        text:
                            "${appTranslation().get("something_went_wrong")}: ${(state as SearchErrorState).error}",
                        color: ColorsManager.error,
                      ),
                      successBuilder: (context) {
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
                            return PrimaryStatusView(
                              icon: Icons.person_search_rounded,
                              text: appTranslation().get("no_user_found"),
                            );
                          }
                        }
                        return PrimaryStatusView(
                          icon: Icons.search_rounded,
                          text: appTranslation().get("search_start_typing"),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
