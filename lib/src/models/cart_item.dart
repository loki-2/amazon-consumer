import 'package:flutter/foundation.dart';

class CartItem {
  final String title;
  final double price;
  final double? originalPrice;
  final String image;
  final String? author;
  int quantity;
  bool isSelected;
  final bool isEligibleForFreeShipping;
  final bool isLimitedTimeDeal;
  final String? purchaseCount;

  CartItem({
    required this.title,
    required this.price,
    this.originalPrice,
    required this.image,
    this.author,
    this.quantity = 1,
    this.isSelected = true,
    this.isEligibleForFreeShipping = false,
    this.isLimitedTimeDeal = false,
    this.purchaseCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'originalPrice': originalPrice,
      'image': image,
      'author': author,
      'quantity': quantity,
      'isSelected': isSelected,
      'isEligibleForFreeShipping': isEligibleForFreeShipping,
      'isLimitedTimeDeal': isLimitedTimeDeal,
      'purchaseCount': purchaseCount,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      title: map['title'] as String,
      price: map['price'] as double,
      originalPrice: map['originalPrice'] as double?,
      image: map['image'] as String,
      author: map['author'] as String?,
      quantity: map['quantity'] as int,
      isSelected: map['isSelected'] as bool,
      isEligibleForFreeShipping: map['isEligibleForFreeShipping'] as bool,
      isLimitedTimeDeal: map['isLimitedTimeDeal'] as bool,
      purchaseCount: map['purchaseCount'] as String?,
    );
  }
}