import 'package:decimal/decimal.dart';

class ProductDetail {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String? imageUrl;
  final String? ingredients;
  final String? topNotes;
  final String? heartNotes;
  final String? baseNotes;
  final String? fragranceDescription;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isFavorite;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    this.imageUrl,
    this.ingredients,
    this.topNotes,
    this.heartNotes,
    this.baseNotes,
    this.fragranceDescription,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final priceDecimal = Decimal.parse(json['price'].toString());
    final ratingDecimal = Decimal.parse(json['rating'].toString());

    return ProductDetail(
      id: json['_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(priceDecimal.toString()) ?? 0.0,
      rating: double.tryParse(ratingDecimal.toString()) ?? 0.0,
      imageUrl: json['imageUrl'],
      ingredients: json['ingredients'],
      topNotes: json['top_notes'],
      heartNotes: json['heart_notes'],
      baseNotes: json['base_notes'],
      fragranceDescription: json['fragrance_description'],
      category: json['category'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      isFavorite: json['is_favorite'] ?? false,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'top_notes': topNotes,
      'heart_notes': heartNotes,
      'base_notes': baseNotes,
      'fragrance_description': fragranceDescription,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}