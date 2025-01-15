import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart/cart_view.dart';
import 'orders/orders_view.dart';
import 'profile/profile_view.dart';
import 'models/book.dart';
import 'product_details_view.dart';
import 'components/location_selection_overlay.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';
  static const Color orangeColor = Color(0xFFFF9900);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // ... [Previous code remains the same until _showLocationSelectionOverlay]

  void _showLocationSelectionOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LocationSelectionOverlay(
        currentAddress: _deliveryLocation,
        onLocationSelected: (location) {
          _updateDeliveryLocation(location);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ... [Rest of the code remains the same]
}

class Deal {
  final String image;
  final String discount;
  final String title;

  Deal({
    required this.image,
    required this.discount,
    required this.title,
  });
}