import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/bible.dart';
import '../services/tts_service.dart';
import '../services/storage_service.dart';
import '../widgets/audio_bar.dart';
import '../widgets/book_selector.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});
  @override State<ReaderScreen> createState() => _ReaderScreenState();
}
class _ReaderScreenState extends State<ReaderScreen> {
  final TTSService _tts = TTSService();
  final ItemScrollController _scroll = ItemScrollController();
  List<Book> _books = [];
  int _b = 0, _c = 0;
  int? _active;
  bool _loading = true;

  @override void initState() { super.initState(); _init(); }

  void _init() async {
    final p = await StorageService.loadPreferences();
    final str = await rootBundle.loadString('assets/es_rvr1960.json');
    final List d = json.decode(str);
    setState(() {
      _books = d.map((x) => Book.fromJson(x)).toList();
      _b = p['bookIndex']; _c = p['chapterIndex']; _tts.speechRate = p['rate'];
      _loading = false;
    });
    _update();
  }

  void _update() {
    _tts.setVerses(_books[_b].chapters[_c]);
    _tts.onVerseStart = (i) {
      setState(() => _active = i);
      _scroll.scrollTo(index: i, duration: const Duration(milliseconds: 300), alignment: 0.35);
    };
    _tts.onChapterEnd = () {
      if (_c + 1 < _books[_b].chapters.length) { _change(_b, _c + 1); _tts.play(fromVerse: 0); }
      else if (_b + 1 < _books.length) { _change(_b + 1, 0); _tts.play(fromVerse: 0); }
    };
  }

  void _change(int b, int c) {
    setState(() { _b = b; _c = c; _active = null; });
    StorageService.saveProgress(b, c);
    _update();
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: Color(0xFF121214), body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))));
    final verses = _books[_b].chapters[_c];
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        title: InkWell(
          onTap: () => showModalBottomSheet(context: context, builder: (_) => BookSelectorSheet(books: _books, activeBook: _b, activeChapter: _c, onSelect: _change)),
          child: Text("${_books[_b].name} ${_c + 1} ▾", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Stack(
        children: [
          ScrollablePositionedList.builder(
            itemScrollController: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: verses.length,
            itemBuilder: (ctx, i) => InkWell(
              onTap: () { _tts.play(fromVerse: i); setState(() {}); },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _active == i ? const Color(0xFF26262B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _active == i ? const Border(left: BorderSide(color: Color(0xFFD4AF37), width: 4)) : null,
                ),
                child: Text("${i + 1}. ${verses[i]}", style: TextStyle(fontSize: 18, color: _active == i ? Colors.white : const Color(0xFFE4E4E7))),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AudioBar(
              isPlaying: _tts.isSpeaking,
              currentRate: _tts.speechRate,
              onPlayPause: () { if (_tts.isSpeaking) _tts.pause(); else _tts.play(fromVerse: _active ?? 0); setState(() {}); },
              onStop: () { _tts.stop(); setState(() => _active = null); },
              onNext: () { _tts.next(); setState(() {}); },
              onPrev: () { _tts.previous(); setState(() {}); },
              onSpeedCycle: () {
                double r = _tts.speechRate == 0.4 ? 0.5 : _tts.speechRate == 0.5 ? 0.6 : 0.4;
                setState(() => _tts.setRate(r));
                StorageService.saveSpeechRate(r);
              },
            ),
          ),
        ],
      ),
    );
  }
}
