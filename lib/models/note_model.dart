class NoteModel {
  final int id;
  final String title;
  final String content;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return NoteModel(
      id: int.tryParse(data['id'].toString()) ?? 0,
      title: (data['title'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, content: $content)';
  }
}