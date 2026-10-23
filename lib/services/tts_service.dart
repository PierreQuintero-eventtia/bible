import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  double speechRate = 0.5;
  Map<String, String>? currentVoice;
  Function(int)? onVerseStart;
  Function()? onChapterEnd;
  List<String> _verses = [];
  int _idx = 0;

  TTSService() {
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(speechRate);
    _tts.setCompletionHandler(() { if (isSpeaking) _speak(_idx + 1); });
    _tts.setErrorHandler((_) => isSpeaking = false);
  }

  Future<List<Map<String, String>>> getSpanishVoices() async {
    try {
      final rawVoices = await _tts.getVoices;
      if (rawVoices is List) {
        final List<Map<String, String>> voices = [];
        for (var v in rawVoices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (locale.toLowerCase().startsWith('es')) {
              voices.add({'name': name, 'locale': locale});
            }
          }
        }
        return voices;
      }
    } catch (_) {}
    return [];
  }

  Future<void> applyVoice(String name, String locale) async {
    currentVoice = {'name': name, 'locale': locale};
    if (name.isNotEmpty && locale.isNotEmpty) {
      await _tts.setVoice({'name': name, 'locale': locale});
    } else if (locale.isNotEmpty) {
      await _tts.setLanguage(locale);
    }
  }

  void setVerses(List<String> v) { _verses = v; stop(); }
  void play({int? fromVerse}) { isSpeaking = true; _speak(fromVerse ?? _idx); }
  void _speak(int i) async {
    if (i >= _verses.length) { isSpeaking = false; onChapterEnd?.call(); return; }
    _idx = i; onVerseStart?.call(i);
    await _tts.speak("${i + 1}. ${_verses[i]}");
  }
  void pause() async { isSpeaking = false; await _tts.stop(); }
  void stop() async { isSpeaking = false; _idx = 0; await _tts.stop(); }
  void next() { if (_idx + 1 < _verses.length) _speak(_idx + 1); else onChapterEnd?.call(); }
  void previous() { if (_idx > 0) _speak(_idx - 1); }
  void setRate(double r) async { speechRate = r; await _tts.setSpeechRate(r); if (isSpeaking) _speak(_idx); }
  
  void speakSample(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
