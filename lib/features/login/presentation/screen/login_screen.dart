import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';
import 'package:piko/features/login/presentation/widgets/email_field.dart';
import 'package:piko/features/login/presentation/widgets/login_button.dart';
import 'package:piko/features/login/presentation/widgets/login_header.dart';
import 'package:piko/features/login/presentation/widgets/password_field.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      buildWhen: (_, state) =>
          state is HomeLoginLoadingState ||
          state is HomeLoginSuccessState ||
          state is HomeLoginErrorState,
      listener: (context, state) {
        if (state is HomeLoginSuccessState) {
          if (state.newUser) {
            context.pushReplacement<Object>(Routes.completeProfile);
          } else {
            context.pushReplacement<Object>(Routes.home);
          }
          homeCubit.emailController.clear();
          homeCubit.passwordController.clear();
        } else if (state is HomeLoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        final isDark = homeCubit.isDarkMode;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const LoginHeader(),
                      verticalSpace40,
                      const EmailField(),
                      verticalSpace20,
                      const PasswordField(),
                      verticalSpace30,
                      LoginButton(
                        formKey: formKey,
                        isLoading: state is HomeLoginLoadingState,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
