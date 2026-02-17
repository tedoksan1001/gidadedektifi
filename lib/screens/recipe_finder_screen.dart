import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/firestore_service.dart';

class RecipeFinderScreen extends StatefulWidget {
  const RecipeFinderScreen({super.key});

  @override
  State<RecipeFinderScreen> createState() => _RecipeFinderScreenState();
}

class _RecipeFinderScreenState extends State<RecipeFinderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _selectedIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  final List<String> _commonIngredients = [
    'Ekmek', 'Süt', 'Yumurta', 'Domates', 'Peynir', 'Patates', 'Pirinç', 'Makarna', 'Yoğurt', 'Tavuk'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Artan Yemek Tarifi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elinizde hangi malzemeler var?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          decoration: const InputDecoration(
                            hintText: 'Örn: Patates, Süt...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) => _addIngredient(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.orange.shade700, size: 30),
                        onPressed: _addIngredient,
                      ),
                    ],
                  ),
                ),
                if (_selectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedIngredients.map((ing) => Chip(
                      label: Text(ing, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.orange.shade900.withOpacity(0.5),
                      deleteIconColor: Colors.white,
                      onDeleted: () => setState(() => _selectedIngredients.remove(ing)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Hızlı Ekle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonIngredients
                      .map(
                        (ingredient) => ActionChip(
                          label: Text(ingredient),
                          onPressed: () => _addQuickIngredient(ingredient),
                          avatar: const Icon(Icons.add, size: 16),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _selectedIngredients.isEmpty
                ? Future.value([])
                : _firestoreService.getRecipesByIngredients(_selectedIngredients),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recipes = snapshot.data ?? [];
                if (_selectedIngredients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text(
                          'Malzeme ekleyerek başlayın.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_food, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text(
                          'Uygun tarif bulunamadı.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        const Text('Farklı malzemeler eklemeyi deneyin.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant, color: Colors.orange),
                        ),
                        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          recipe.ingredients.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showRecipeDetails(recipe),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isEmpty) return;

    final alreadyAdded = _selectedIngredients
        .map((item) => item.toLowerCase())
        .contains(ingredient.toLowerCase());

    if (alreadyAdded) {
      _ingredientController.clear();
      return;
    }

    setState(() {
      _selectedIngredients.add(ingredient);
      _ingredientController.clear();
    });
  }

  void _addQuickIngredient(String ingredient) {
    _ingredientController.text = ingredient;
    _addIngredient();
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(recipe.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (recipe.country.isNotEmpty)
               Text('Köken: ${recipe.country}', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
            const Divider(height: 32),
            const Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text('Malzemeler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: recipe.ingredients.map((ing) => Chip(
                label: Text(ing, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange.shade50,
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text('Hazırlanışı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  recipe.instructions,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
