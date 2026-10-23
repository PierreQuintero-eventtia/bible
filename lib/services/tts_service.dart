import 'package:flutter_tts/flutter_tts.dart';
class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  double speechRate = 0.5;
  Function(int)? onVerseStart;
  Function()? onChapterEnd;
  List<String> _verses = [];
  int _idx = 0;
  TTSService() {
    _tts.setLanguage("es-ES");
    _tts.setSpeechRate(speechRate);
    _tts.setCompletionHandler(() { if (isSpeaking) _speak(_idx + 1); });
    _tts.setErrorHandler((_) => isSpeaking = false);
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
}
