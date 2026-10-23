class Category {
  const Category({required this.id, required this.name, this.description = ''});

  final String id;
  final String name;
  final String description;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
      );

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
