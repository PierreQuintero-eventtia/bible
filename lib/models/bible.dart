class Book {
  final String name;
  final String abbrev;
  final List<List<String>> chapters;
  Book({required this.name, required this.abbrev, required this.chapters});
  factory Book.fromJson(Map<String, dynamic> json) {
    var raw = json['chapters'] as List;
    List<List<String>> c = raw.map((ch) => (ch as List).map((v) => v.toString()).toList()).toList();
    return Book(name: json['name'] ?? '', abbrev: json['abbrev'] ?? '', chapters: c);
  }
}
