class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String country;
  final bool isTraditional;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.country,
    this.isTraditional = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'country': country,
      'isTraditional': isTraditional,
    };
  }

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      country: map['country'] ?? '',
      isTraditional: map['isTraditional'] ?? false,
    );
  }
}
