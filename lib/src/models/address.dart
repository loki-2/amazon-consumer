import 'package:flutter/foundation.dart';

class Address {
  final String id;
  final String name;
  final String mobile;
  final String flat;
  final String area;
  final String landmark;
  final String pincode;
  final String city;
  final String state;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.mobile,
    required this.flat,
    required this.area,
    required this.landmark,
    required this.pincode,
    required this.city,
    required this.state,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'flat': flat,
      'area': area,
      'landmark': landmark,
      'pincode': pincode,
      'city': city,
      'state': state,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      flat: map['flat'] as String,
      area: map['area'] as String,
      landmark: map['landmark'] as String,
      pincode: map['pincode'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      isDefault: map['isDefault'] as bool,
    );
  }
}