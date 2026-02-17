import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/firestore_service.dart';

class ETwinningScreen extends StatefulWidget {
  const ETwinningScreen({super.key});

  @override
  State<ETwinningScreen> createState() => _ETwinningScreenState();
}

class _ETwinningScreenState extends State<ETwinningScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final countryController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Geleneksel Tarif Paylaş', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'eTwinning topluluğu ile ülkenizin geleneksel değerlendirme tarifini paylaşın.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Tarif Adı',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: InputDecoration(
                  labelText: 'Ülke',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Malzemeler (Virgülle ayırın)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Ekmek, Süt, Şeker...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructionsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Nasıl Yapılır?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || countryController.text.isEmpty) return;

              final recipe = Recipe(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                country: countryController.text,
                ingredients: ingredientsController.text.split(',').map((e) => e.trim()).toList(),
                instructions: instructionsController.text,
                isTraditional: true,
              );
              await _firestoreService.addRecipe(recipe);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarifiniz başarıyla eklendi!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Paylaş'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('eTwinning: Geleneksel Lezzetler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecipeDialog,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tarif Ekle'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.purple.shade700,
            width: double.infinity,
            child: const Text(
              'Dünyanın dört bir yanından geleneksel "artan yemekleri değerlendirme" tariflerini keşfedin.',
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Recipe>>(
              stream: _firestoreService.getTraditionalRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.public_off, size: 80, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz geleneksel tarif eklenmemiş.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.public, color: Colors.purple),
                        ),
                        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.flag_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(recipe.country),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(recipe.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text(recipe.country, style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 32),
            const Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text('Malzemeler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: recipe.ingredients.map((ing) => Chip(
                label: Text(ing, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.purple.shade50,
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: Colors.purple),
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
