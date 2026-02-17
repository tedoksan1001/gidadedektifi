import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/recipe.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Product> _localProducts = [];
  final List<Recipe> _localRecipes = [
    Recipe(
      id: 'sample-1',
      title: 'Bayat Ekmek Köftesi',
      ingredients: ['Bayat ekmek', 'Soğan', 'Yumurta', 'Maydanoz'],
      instructions:
          'Bayat ekmekleri ıslatıp sıkın. Rendelenmiş soğan, yumurta ve baharatlarla yoğurun. Kızgın yağda veya fırında pişirerek servis edin.',
      country: 'Türkiye',
      isTraditional: true,
    ),
    Recipe(
      id: 'sample-2',
      title: 'Tortilla Española (Artan Patatesli)',
      ingredients: ['Patates', 'Yumurta', 'Soğan', 'Zeytinyağı'],
      instructions:
          'Patates ve soğanı soteleyin. Çırpılmış yumurtayla karıştırıp tavada iki tarafını da pişirin.',
      country: 'İspanya',
      isTraditional: true,
    ),
  ];

  Future<void> addProduct(Product product) async {
    _localProducts.removeWhere((item) => item.id == product.id);
    _localProducts.add(product);

    try {
      await _db.collection('products').doc(product.id).set(product.toMap());
    } catch (_) {
      // İnternet/Firebase hatasında yerel liste korunur.
    }
  }

  Stream<List<Product>> getProducts() async* {
    if (_localProducts.isNotEmpty) {
      yield _sortedProducts([..._localProducts]);
    }

    try {
      yield* _db
          .collection('products')
          .orderBy('expiryDate')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Product.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      yield _sortedProducts([..._localProducts]);
    }
  }

  Future<void> deleteProduct(String id) async {
    _localProducts.removeWhere((item) => item.id == id);
    try {
      await _db.collection('products').doc(id).delete();
    } catch (_) {
      // İnternet/Firebase hatasında yerel liste korunur.
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _localRecipes.removeWhere((item) => item.id == recipe.id);
    _localRecipes.add(recipe);

    try {
      await _db.collection('recipes').doc(recipe.id).set(recipe.toMap());
    } catch (_) {
      // İnternet/Firebase hatasında yerel liste korunur.
    }
  }

  Stream<List<Recipe>> getRecipes() async* {
    if (_localRecipes.isNotEmpty) {
      yield [..._localRecipes];
    }

    try {
      yield* _db.collection('recipes').snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => Recipe.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      yield [..._localRecipes];
    }
  }

  Future<List<Recipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      return [];
    }

    final normalized = ingredients.map((item) => item.toLowerCase().trim()).toSet();

    try {
      final snapshot = await _db
          .collection('recipes')
          .where('ingredients', arrayContainsAny: normalized.take(10).toList())
          .get();

      final remoteRecipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data()))
          .toList();

      return _sortRecipesByMatch(remoteRecipes, normalized);
    } catch (_) {
      final filtered = _localRecipes.where((recipe) {
        final ingredientsLower = recipe.ingredients.map((item) => item.toLowerCase());
        return ingredientsLower.any(normalized.contains);
      }).toList();

      return _sortRecipesByMatch(filtered, normalized);
    }
  }

  Stream<List<Recipe>> getTraditionalRecipes() async* {
    final localTraditional =
        _localRecipes.where((item) => item.isTraditional).toList();
    if (localTraditional.isNotEmpty) {
      yield localTraditional;
    }

    try {
      yield* _db
          .collection('recipes')
          .where('isTraditional', isEqualTo: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Recipe.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      yield localTraditional;
    }
  }

  List<Product> _sortedProducts(List<Product> products) {
    products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return products;
  }

  List<Recipe> _sortRecipesByMatch(List<Recipe> recipes, Set<String> normalized) {
    recipes.sort((a, b) {
      final aMatch = a.ingredients
          .where((item) => normalized.contains(item.toLowerCase()))
          .length;
      final bMatch = b.ingredients
          .where((item) => normalized.contains(item.toLowerCase()))
          .length;
      return bMatch.compareTo(aMatch);
    });
    return recipes;
  }
}
