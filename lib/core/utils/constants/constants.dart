import 'package:piko/core/utils/constants/translations.dart';
import 'package:piko/core/utils/cubit/theme/theme_cubit.dart';

TranslationModel appTranslation() =>
    themeCubit.translationModel ?? TranslationModel.fromJson({});
