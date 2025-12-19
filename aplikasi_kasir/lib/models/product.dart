class Product {
  String id, name, category;
  double price;
  int stock, minStock;

  Product({
    required this.id, 
    required this.name, 
    required this.category, 
    required this.price, 
    required this.stock, 
    required this.minStock
  });

  // Fungsi konversi JSON
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    price: json['price'].toDouble(),
    stock: json['stock'],
    minStock: json['minStock'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category, 
    'price': price, 'stock': stock, 'minStock': minStock,
  };
}