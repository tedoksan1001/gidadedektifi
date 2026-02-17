import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/recipe.dart';

class FirestoreService {
  FirestoreService() {
    _seedInitialData();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Product> _localProducts = [];
  final List<Recipe> _localRecipes = [];

  final StreamController<List<Product>> _productsController =
      StreamController<List<Product>>.broadcast();
  final StreamController<List<Recipe>> _recipesController =
      StreamController<List<Recipe>>.broadcast();

  bool _seeded = false;

  void _seedInitialData() {
    if (_seeded) {
      return;
    }

    _localRecipes.addAll([
      Recipe(
        id: 'sample-1',
        title: 'Bayat Ekmek Köftesi',
        ingredients: const ['Bayat ekmek', 'Soğan', 'Yumurta', 'Maydanoz'],
        instructions:
            'Bayat ekmekleri ıslatıp sıkın. Rendelenmiş soğan, yumurta ve baharatlarla yoğurun. '
            'Kızgın yağda veya fırında pişirerek servis edin.',
        country: 'Türkiye',
        isTraditional: true,
      ),
      Recipe(
        id: 'sample-2',
        title: 'Tortilla Española (Artan Patatesli)',
        ingredients: const ['Patates', 'Yumurta', 'Soğan', 'Zeytinyağı'],
        instructions:
            'Patates ve soğanı soteleyin. Çırpılmış yumurtayla karıştırıp tavada iki tarafını da pişirin.',
        country: 'İspanya',
        isTraditional: true,
      ),
      Recipe(
        id: 'sample-3',
        title: 'Sebzeli Frittata',
        ingredients: const ['Yumurta', 'Peynir', 'Domates', 'Biber'],
        instructions:
            'Artan sebzeleri tavada çevirin. Yumurta ve peynir karışımını ekleyip kısık ateşte pişirin.',
        country: 'İtalya',
      ),
      Recipe(
        id: 'sample-4',
        title: 'Yoğurtlu Makarna Salatası',
        ingredients: const ['Makarna', 'Yoğurt', 'Mısır', 'Havuç'],
        instructions:
            'Haşlanmış artan makarnayı yoğurtlu sos ve sebzelerle karıştırın. Soğuk servis edin.',
        country: 'Türkiye',
      ),
    ]);

    _seeded = true;
    _emitProducts();
    _emitRecipes();
  }

  void _emitProducts() {
    final sorted = [..._localProducts]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    _productsController.add(sorted);
  }

  void _emitRecipes() {
    _recipesController.add([..._localRecipes]);
  }

  // Products
  Future<void> addProduct(Product product) async {
    _seedInitialData();
    _localProducts.removeWhere((item) => item.id == product.id);
    _localProducts.add(product);
    _emitProducts();

    try {
      await _db.collection('products').doc(product.id).set(product.toMap());
    } catch (_) {
      // Firebase kullanılamadığında yerel veri ile devam edilir.
    }
  }

  Stream<List<Product>> getProducts() {
    _seedInitialData();

    final remoteStream = _db
        .collection('products')
        .orderBy('expiryDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );

    return remoteStream.handleError((_) {}).onErrorReturnWith((_) {
      _emitProducts();
      return [..._localProducts]..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    });
  }

  Future<void> deleteProduct(String id) async {
    _seedInitialData();
    _localProducts.removeWhere((item) => item.id == id);
    _emitProducts();

    try {
      await _db.collection('products').doc(id).delete();
    } catch (_) {
      // Firebase kullanılamadığında yerel veri ile devam edilir.
    }
  }

  // Recipes
  Future<void> addRecipe(Recipe recipe) async {
    _seedInitialData();
    _localRecipes.removeWhere((item) => item.id == recipe.id);
    _localRecipes.add(recipe);
    _emitRecipes();

    try {
      await _db.collection('recipes').doc(recipe.id).set(recipe.toMap());
    } catch (_) {
      // Firebase kullanılamadığında yerel veri ile devam edilir.
    }
  }

  Stream<List<Recipe>> getRecipes() {
    _seedInitialData();

    final remoteStream = _db.collection('recipes').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );

    return remoteStream.handleError((_) {}).onErrorReturnWith((_) {
      _emitRecipes();
      return [..._localRecipes];
    });
  }

  Future<List<Recipe>> getRecipesByIngredients(List<String> ingredients) async {
    _seedInitialData();
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

      if (remoteRecipes.isNotEmpty) {
        return _sortRecipesByMatch(remoteRecipes, normalized);
      }
    } catch (_) {
      // Firebase kullanılamadığında yerel veri ile devam edilir.
    }

    final filtered = _localRecipes.where((recipe) {
      final ingredientsLower = recipe.ingredients.map((item) => item.toLowerCase());
      return ingredientsLower.any(normalized.contains);
    }).toList();

    return _sortRecipesByMatch(filtered, normalized);
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

  Stream<List<Recipe>> getTraditionalRecipes() {
    _seedInitialData();

    final remoteStream = _db
        .collection('recipes')
        .where('isTraditional', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );

    return remoteStream.handleError((_) {}).onErrorReturnWith((_) {
      return _localRecipes.where((item) => item.isTraditional).toList();
    });
  }
}

extension<T> on Stream<T> {
  Stream<T> onErrorReturnWith(T Function(Object) fallback) async* {
    try {
      await for (final value in this) {
        yield value;
      }
    } catch (error) {
      yield fallback(error);
    }
  }
}
