class Note {
  //note properties
  final int? id;
  String content;
  bool isFavorite;

  //constructor with named parameters
  Note({
    this.id,
    required this.content,
    required this.isFavorite,
  });

  //factory constructor to create a Note object from a map of values
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      content: json['body'] as String,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
  //Method to convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'body': content, //Serialized to JSON
      'is_favorite': isFavorite,
    };
  }
}
