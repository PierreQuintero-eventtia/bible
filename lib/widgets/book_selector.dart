import 'package:flutter/material.dart';
import '../models/bible.dart';
class BookSelectorSheet extends StatefulWidget {
  final List<Book> books; final int activeBook, activeChapter; final Function(int, int) onSelect;
  const BookSelectorSheet({super.key, required this.books, required this.activeBook, required this.activeChapter, required this.onSelect});
  @override State<BookSelectorSheet> createState() => _BookSelectorSheetState();
}
class _BookSelectorSheetState extends State<BookSelectorSheet> {
  late int selectedBook;
  @override void initState() { super.initState(); selectedBook = widget.activeBook; }
  @override Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      color: const Color(0xFF16161A),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: ListView.builder(
              itemCount: widget.books.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(widget.books[i].name, style: TextStyle(color: i == selectedBook ? const Color(0xFFD4AF37) : Colors.white70)),
                onTap: () => setState(() => selectedBook = i),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: widget.books[selectedBook].chapters.length,
              itemBuilder: (ctx, c) => InkWell(
                onTap: () { widget.onSelect(selectedBook, c); Navigator.pop(context); },
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF202026), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text("${c + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
