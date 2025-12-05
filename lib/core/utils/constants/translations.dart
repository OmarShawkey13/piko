class TranslationModel {
  final Map<String, String> data;

  TranslationModel.fromJson(Map<String, dynamic> json)
    : data = json.map((key, value) => MapEntry(key, value.toString()));

  String get(String key) => data[key] ?? key;
}
