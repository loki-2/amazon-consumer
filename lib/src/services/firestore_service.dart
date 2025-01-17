import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToCart(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.title)
          .set(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      return snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  Future<void> removeFromCart(String itemTitle) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemTitle)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> updateCartItemQuantity(String itemTitle, int newQuantity) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemTitle)
          .update({'quantity': newQuantity});
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      print('Adding product to Firestore: ${product.toMap()}');
      await _firestore.collection('products').doc(product.id).set(product.toMap());
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      print('Fetching products from Firestore...');
      final snapshot = await _firestore.collection('products').get();
      print('Retrieved ${snapshot.docs.length} products from Firestore');
      return snapshot.docs.map((doc) {
        try {
          print('Processing product document: ${doc.id}');
          print('Document data: ${doc.data()}');
          return Product.fromMap(doc.data(), doc.id);
        } catch (e) {
          print('Error processing product ${doc.id}: $e');
          return Product(
            id: doc.id,
            productName: 'Error Loading Product',
            price: 0.0,
          );
        }
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to get products: $e');
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      print('Received product stream update with ${snapshot.docs.length} products');
      return snapshot.docs.map((doc) {
        try {
          return Product.fromMap(doc.data(), doc.id);
        } catch (e) {
          print('Error processing product in stream ${doc.id}: $e');
          return Product(
            id: doc.id,
            productName: 'Error Loading Product',
            price: 0.0,
          );
        }
      }).toList();
    });
  }
}