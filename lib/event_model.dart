class Event {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;
  final String category;

  Event({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description = '',
    this.category = 'General',
  });

  // JSON 데이터로부터 Event 객체를 생성하는 팩토리 생성자
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
    );
  }

  // Event 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'description': description,
      'category': category,
    };
  }
}
