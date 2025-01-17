import 'package:flutter/material.dart';
import '../checkout/checkout_view.dart';
import '../sample_feature/home_view.dart';
import '../orders/orders_view.dart';
import '../components/amazon_search_bar.dart';
import '../components/bottom_nav_bar.dart';
import '../profile/profile_view.dart';
import '../models/cart_item.dart';
import '../services/firestore_service.dart';

class CartView extends StatefulWidget {
  static const routeName = '/cart';
  static const Color orangeColor = Color(0xFFFF9900);

  static Future<void> addToCart(CartItem newItem) async {
    final firestoreService = FirestoreService();
    await firestoreService.addToCart(newItem);
  }

  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _allItemsSelected = true;
  int _selectedIndex = 3;
  final FirestoreService _firestoreService = FirestoreService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _firestoreService.getCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cart: $e')),
        );
      }
    }
  }

  double get _subtotal => _cartItems.fold(
        0,
        (sum, item) => item.isSelected ? sum + (item.price * item.quantity) : sum,
      );

  double get _deliveryCharge => 200.00;
  bool get _isEligibleForFreeDelivery => _subtotal >= 499;

  int get _selectedItemCount => _cartItems.where((item) => item.isSelected).length;

  void _toggleSelectAll() {
    setState(() {
      _allItemsSelected = !_allItemsSelected;
      for (var item in _cartItems) {
        item.isSelected = _allItemsSelected;
      }
    });
  }

  Future<void> _updateQuantity(int index, bool increase) async {
    try {
      final item = _cartItems[index];
      final newQuantity = increase ? item.quantity + 1 : item.quantity - 1;

      if (newQuantity <= 0) {
        await _firestoreService.removeFromCart(item.title);
        setState(() {
          _cartItems.removeAt(index);
          _allItemsSelected = _cartItems.isNotEmpty && 
                            _cartItems.every((item) => item.isSelected);
        });
      } else {
        await _firestoreService.updateCartItemQuantity(item.title, newQuantity);
        setState(() {
          item.quantity = newQuantity;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quantity: $e')),
        );
      }
    }
  }

  void _updateItemSelection(int index, bool? value) {
    setState(() {
      _cartItems[index].isSelected = value ?? false;
      _allItemsSelected = _cartItems.every((item) => item.isSelected);
    });
  }

  void _proceedToCheckout() {
    Navigator.pushNamed(context, CheckoutView.routeName);
  }

  void _onNavigationItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, HomeView.routeName);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, ProfileView.routeName);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, OrdersView.routeName);
    }
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/cart/empty_cart.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to start shopping',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, HomeView.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CartView.orangeColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: AmazonSearchBar(),
              ),
            ),
          ),
        ),
        body: _buildEmptyCart(),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onNavigationItemTapped,
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AmazonSearchBar(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Subtotal ₹${_subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('EMI Available', style: TextStyle(fontSize: 16)),
                ),
                if (_isEligibleForFreeDelivery)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.green.shade50,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.green.shade700),
                              children: const [
                                TextSpan(
                                  text: 'Your order is eligible for FREE Delivery. ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: 'Choose FREE Delivery option at checkout.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _selectedItemCount > 0 ? _proceedToCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CartView.orangeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Proceed to Buy (${_selectedItemCount} items)',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: _toggleSelectAll,
                  icon: Icon(
                    _allItemsSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: CartView.orangeColor,
                  ),
                  label: Text(
                    _allItemsSelected ? 'Deselect all items' : 'Select all items',
                    style: TextStyle(color: CartView.orangeColor),
                  ),
                ),
                const Divider(),
                ..._cartItems.asMap().entries.map((entry) => _buildCartItem(entry.key, entry.value)).toList(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Items:', style: TextStyle(fontSize: 16)),
                    Text('₹${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedItemCount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery:', style: TextStyle(fontSize: 16)),
                      Text('₹${_deliveryCharge.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  if (_isEligibleForFreeDelivery) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FREE Delivery:', style: TextStyle(fontSize: 16)),
                        Text('-₹${_deliveryCharge.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ],
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      _selectedItemCount > 0
                          ? '₹${(_isEligibleForFreeDelivery ? _subtotal : _subtotal + _deliveryCharge).toStringAsFixed(2)}'
                          : '₹0.00',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
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

  Widget _buildCartItem(int index, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: item.isSelected,
                onChanged: (value) => _updateItemSelection(index, value),
                activeColor: CartView.orangeColor,
              ),
              Image.asset(
                item.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'by ${item.author}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.originalPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'M.R.P.: ₹${item.originalPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.isEligibleForFreeShipping)
                      const Text(
                        'Eligible for FREE Shipping',
                        style: TextStyle(color: Colors.grey),
                      ),
                    if (item.purchaseCount != null)
                      Text(
                        item.purchaseCount!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    if (item.isLimitedTimeDeal)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Limited time deal',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateQuantity(index, false),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateQuantity(index, true),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save for later'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}