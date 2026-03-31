import 'package:piko/core/utils/cubit/auth/auth_cubit.dart';
import 'package:piko/core/utils/cubit/home/home_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => HomeCubit());
  sl.registerFactory(() => ChatCubit());
  sl.registerFactory(() => ThemeCubit());

  final sharedPref = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPref);
}
