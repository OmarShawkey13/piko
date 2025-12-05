import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/utils/constants/assets_helper.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/features/on_boarding/data/models/onboarding_item.dart';
import 'package:piko/features/on_boarding/presentation/widgets/onboarding_footer.dart';
import 'package:piko/features/on_boarding/presentation/widgets/onboarding_indicator.dart';
import 'package:piko/features/on_boarding/presentation/widgets/onboarding_page_item.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<OnBoardingItem> pages = [
    OnBoardingItem(
      title: appTranslation().get("page1_title"),
      subtitle: appTranslation().get("page1_subtitle"),
      image: AssetsHelper.logo,
    ),
    OnBoardingItem(
      title: appTranslation().get("page2_title"),
      subtitle: appTranslation().get("page2_subtitle"),
      image: AssetsHelper.onboarding2,
    ),
    OnBoardingItem(
      title: appTranslation().get("page3_title"),
      subtitle: appTranslation().get("page3_subtitle"),
      image: AssetsHelper.onboarding3,
    ),
  ];

  bool get isLast => _index == pages.length - 1;

  Future<void> finish() async {
    await CacheHelper.saveData(key: 'onBoarding', value: true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: homeCubit.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (_, i) => OnBoardingPageItem(item: pages[i]),
                ),
              ),
              OnBoardingIndicator(currentIndex: _index, length: pages.length),
              OnBoardingFooter(
                isLast: isLast,
                onSkip: finish,
                onNext: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                ),
                onStart: finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
