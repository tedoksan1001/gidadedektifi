import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/recipe.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Products
  Future<void> addProduct(Product product) {
    return _db.collection('products').doc(product.id).set(product.toMap());
  }

  Stream<List<Product>> getProducts() {
    return _db.collection('products')
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> deleteProduct(String id) {
    return _db.collection('products').doc(id).delete();
  }

  // Recipes
  Future<void> addRecipe(Recipe recipe) {
    return _db.collection('recipes').doc(recipe.id).set(recipe.toMap());
  }

  Stream<List<Recipe>> getRecipes() {
    return _db.collection('recipes').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<Recipe>> getRecipesByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    // Firestore'un array-contains-any limiti 10 malzemedir.
    List<String> searchList = ingredients.take(10).toList();

    try {
      QuerySnapshot snapshot = await _db.collection('recipes')
          .where('ingredients', arrayContainsAny: searchList)
          .get();

      return snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Arama hatası: $e');
      // Hata durumunda (örneğin index eksikliği) boş liste dön.
      return [];
    }
  }

  Stream<List<Recipe>> getTraditionalRecipes() {
    return _db.collection('recipes')
        .where('isTraditional', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList());
  }
}
