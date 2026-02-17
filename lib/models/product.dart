class Product {
  final String id;
  final String barcode;
  final String name;
  final DateTime expiryDate;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      expiryDate: DateTime.parse(map['expiryDate']),
    );
  }
}
