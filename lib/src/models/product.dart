class Product {
  final String id;
  final String productName;
  final String? category;
  final double price;
  final String? imageUrl;
  final String? description;
  final bool isLimitedTimeDeal;
  final bool isEligibleForFreeShipping;
  final double? originalPrice;
  final String? brand;

  Product({
    required this.id,
    required this.productName,
    this.category,
    required this.price,
    this.imageUrl,
    this.description,
    this.isLimitedTimeDeal = false,
    this.isEligibleForFreeShipping = false,
    this.originalPrice,
    this.brand,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    // First try to get the name from 'name' field
    String? name = map['name'] as String?;
    
    // If 'name' is null, try 'productName'
    if (name == null) {
      name = map['productName'] as String?;
    }
    
    // If both are null, try 'title'
    if (name == null) {
      name = map['title'] as String?;
    }
    
    // If all attempts fail, use default
    if (name == null || name.isEmpty) {
      name = 'Product ${id.substring(0, 4)}';
    }

    return Product(
      id: id,
      productName: name,
      category: map['category'] as String?,
      price: (map['price'] is num) 
          ? (map['price'] as num).toDouble() 
          : double.tryParse(map['price'].toString()) ?? 0.0,
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      isLimitedTimeDeal: map['isLimitedTimeDeal'] as bool? ?? false,
      isEligibleForFreeShipping: map['isEligibleForFreeShipping'] as bool? ?? false,
      originalPrice: map['originalPrice'] != null 
          ? (map['originalPrice'] is num)
              ? (map['originalPrice'] as num).toDouble()
              : double.tryParse(map['originalPrice'].toString())
          : null,
      brand: map['brand'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'isLimitedTimeDeal': isLimitedTimeDeal,
      'isEligibleForFreeShipping': isEligibleForFreeShipping,
      'originalPrice': originalPrice,
      'brand': brand,
    };
  }
}