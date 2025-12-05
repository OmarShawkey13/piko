import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/models/user_model.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/features/chat/presentation/screen/chat_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = homeCubit.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(context, isDark),
            verticalSpace24,
            Expanded(
              child: BlocBuilder<HomeCubit, HomeStates>(
                buildWhen: (_, state) =>
                    state is SearchInitialState ||
                    state is SearchLoadingState ||
                    state is SearchSuccessState ||
                    state is SearchErrorState,
                builder: (context, state) {
                  return _buildResultWidget(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return TextField(
      onChanged: (value) => homeCubit.searchUsername(value),
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        hintText: "Search username...",
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildResultWidget(BuildContext context, HomeStates state) {
    if (state is SearchLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    String hintText = "Search for a username";
    if (state is SearchErrorState) {
      hintText = "Error: ${state.error}";
    } else if (state is SearchSuccessState) {
      final user = state.user;
      if (user != null) {
        return Align(
          alignment: Alignment.topCenter,
          child: UserTile(user: user),
        );
      } else {
        hintText = "No user found";
      }
    }
    return Center(
      child: Text(
        hintText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final UserModel user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<Widget>(
            builder: (_) => ChatScreen(user: user),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.photoUrl.isNotEmpty
            ? NetworkImage(user.photoUrl)
            : null,
        child: user.photoUrl.isEmpty
            ? const Icon(Icons.person, size: 28)
            : null,
      ),
      title: Text(
        user.displayName.isNotEmpty ? user.displayName : user.username,
        style: theme.textTheme.titleMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "@${user.username}",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.hintColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
    );
  }
}
