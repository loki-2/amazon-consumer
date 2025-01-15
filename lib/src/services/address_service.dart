import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      if (address.isDefault) {
        // If new address is default, remove default status from other addresses
        await _removeDefaultStatus(user.uid);
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc()  // Changed: Let Firestore generate a unique ID
          .set(address.toMap());
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> updateAddress(Address address) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      if (address.isDefault) {
        // If updated address is default, remove default status from other addresses
        await _removeDefaultStatus(user.uid);
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id)
          .update(address.toMap());
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  Future<List<Address>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;  // Add document ID to the data
        return Address.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get addresses: $e');
    }
  }

  Future<void> _removeDefaultStatus(String userId) async {
    final addressesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in addressesSnapshot.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }
}