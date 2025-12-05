import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piko/core/di/injections.dart';
import 'package:piko/core/network/local/cache_helper.dart';
import 'package:piko/core/network/service/notification_handler.dart';
import 'package:piko/core/theme/theme.dart';
import 'package:piko/core/utils/constants/my_bloc_observer.dart';
import 'package:piko/core/utils/constants/routes.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';
import 'package:piko/core/utils/cubit/home_state.dart';
import 'package:piko/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjections();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.initialize("f2640e97-2e4a-4f4f-b727-d5fee0a92045");
  OneSignal.Notifications.requestPermission(true);
  await NotificationHandler.initialize();
  final bool isDark = CacheHelper.getData(key: 'isDark') ?? false;
  final bool isArabic = CacheHelper.getData(key: 'isArabicLang') ?? false;
  final String translation = await rootBundle.loadString(
    'assets/translations/${isArabic ? 'ar' : 'en'}.json',
  );
  Bloc.observer = MyBlocObserver();
  runApp(
    MyApp(
      isDark: isDark,
      isArabic: isArabic,
      translation: translation,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final bool isArabic;
  final String translation;

  const MyApp({
    super.key,
    required this.isDark,
    required this.isArabic,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeCubit>()
        ..changeTheme(
          fromShared: isDark,
        )
        ..initializeLanguage(
          isArabic: isArabic,
          translations: translation,
        ),
      child: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          routes: Routes.routes,
          initialRoute: Routes.enterRoute,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: HomeCubit.get(context).isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          builder: (c, widget) {
            return Directionality(
              textDirection: HomeCubit.get(context).isArabicLang
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: widget!,
            );
          },
        ),
      ),
    );
  }
}
