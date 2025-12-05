import 'package:piko/core/utils/constants/translations.dart';
import 'package:piko/core/utils/cubit/home_cubit.dart';

TranslationModel appTranslation() =>
    homeCubit.translationModel ?? TranslationModel.fromJson({});
