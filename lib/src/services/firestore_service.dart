import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

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

  Future<void> addAddress(Map<String, dynamic> address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      if (address['isDefault'] == true) {
        // If new address is default, remove default status from other addresses
        final addressesSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .get();

        for (var doc in addressesSnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add(address);
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get addresses: $e');
    }
  }
}