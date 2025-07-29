class Favorite {
  final int id;
  final String name;
  final String description;
  final double rating;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Favorite({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rating: double.parse(json['rating'].toString()),
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rating': rating,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}