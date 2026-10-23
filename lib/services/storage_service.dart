import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveProgress(int b, int c) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('b', b); await p.setInt('c', c);
  }

  static Future<void> saveSpeechRate(double r) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('r', r);
  }

  static Future<void> saveVoice(String name, String locale) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('v_name', name);
    await p.setString('v_locale', locale);
  }

  static Future<Map<String, dynamic>> loadPreferences() async {
    final p = await SharedPreferences.getInstance();
    return {
      'bookIndex': p.getInt('b') ?? 0,
      'chapterIndex': p.getInt('c') ?? 0,
      'rate': p.getDouble('r') ?? 0.5,
      'voiceName': p.getString('v_name') ?? '',
      'voiceLocale': p.getString('v_locale') ?? '',
    };
  }
}
