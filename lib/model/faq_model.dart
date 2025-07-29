class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final DateTime createdAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.createdAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['_id'] ?? '',
      question: json['pertanyaan'] ?? '',
      answer: json['jawaban'] ?? '',
      category: json['kategori'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pertanyaan': question,
      'jawaban': answer,
      'kategori': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
