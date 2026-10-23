class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.instructor,
    required this.price,
    required this.duration,
    required this.thumbnail,
    required this.trailerUrl,
    required this.createdAt,
  });

  final String id, title, description, categoryId, instructor, duration, thumbnail, trailerUrl, createdAt;
  final double price;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: '${json['id'] ?? ''}', title: '${json['title'] ?? ''}',
        description: '${json['description'] ?? ''}', categoryId: '${json['categoryId'] ?? ''}',
        instructor: '${json['instructor'] ?? ''}', price: double.tryParse('${json['price'] ?? 0}') ?? 0,
        duration: '${json['duration'] ?? ''}', thumbnail: '${json['thumbnail'] ?? ''}',
        trailerUrl: '${json['trailerUrl'] ?? ''}', createdAt: '${json['createdAt'] ?? ''}',
      );

  Map<String, dynamic> toJson() => {
        'title': title, 'description': description, 'categoryId': categoryId,
        'instructor': instructor, 'price': price, 'duration': duration,
        'thumbnail': thumbnail, 'trailerUrl': trailerUrl, 'createdAt': createdAt,
      };
}
