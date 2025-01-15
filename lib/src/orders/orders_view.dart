import 'package:flutter/material.dart';
import '../components/amazon_search_bar.dart';
import '../sample_feature/home_view.dart';
import '../cart/cart_view.dart';
import '../components/bottom_nav_bar.dart';
import '../profile/profile_view.dart';

class OrdersView extends StatefulWidget {
  static const routeName = '/orders';
  static const Color orangeColor = Color(0xFFFF9900);

  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 2;

  void _onNavigationItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, HomeView.routeName);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, ProfileView.routeName);
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, CartView.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: AmazonSearchBar(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Your Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.blue[700],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '2024',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildOrderItem(
                    'ASIAN Men\'s Achiever-15 Latest...',
                    'Delivered 15-Dec-2022',
                    'assets/images/orders/shoes_blue.png',
                  ),
                  _buildOrderItem(
                    'Exchanged',
                    'We are expecting the return of the original item.',
                    'assets/images/orders/shoes_grey.png',
                  ),
                  _buildOrderItem(
                    'Exchange Pick-up Service for Mobiles',
                    'Not yet dispatched',
                    'assets/images/orders/exchange_icon.png',
                  ),
                  _buildOrderItem(
                    'Redmi Note 11 (Starburst White, 4GB...',
                    'Ordered on 26-Sep-2022',
                    'assets/images/orders/phone.png',
                  ),
                  _buildOrderItem(
                    'Cello Novelty Big Plastic 2 Door...',
                    'Delivered',
                    'assets/images/orders/cabinet.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationItemTapped,
      ),
    );
  }

  Widget _buildOrderItem(String title, String subtitle, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Image.asset(
          imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {},
      ),
    );
  }
}