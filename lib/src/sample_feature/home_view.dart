import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cart/cart_view.dart';
import '../orders/orders_view.dart';
import '../profile/profile_view.dart';
import '../models/book.dart';
import 'product_details_view.dart';
import '../components/location_selection_overlay.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';
  static const Color orangeColor = Color(0xFFFF9900);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  String _deliveryLocation = 'Select your location';
  final FirestoreService _firestoreService = FirestoreService();
  List<Product> _products = [];
  bool _isLoadingProducts = true;

  final List<String> _bannerImages = [
    'assets/images/banners/appliances_banner.png',
    'assets/images/banners/appliances_banner.png',
    'assets/images/banners/appliances_banner.png',
  ];

  final List<Deal> _deals = [
    Deal(
      image: 'assets/images/deals/blender1.png',
      discount: '58',
      title: 'Limited time deal',
    ),
    Deal(
      image: 'assets/images/deals/blender2.png',
      discount: '63',
      title: 'Limited time deal',
    ),
  ];

  final List<Book> _books = [
    Book(
      title: 'The Alchemist',
      image: 'assets/images/books/alchemist.png',
      price: 259,
      originalPrice: 399,
      author: 'Paulo Coelho',
    ),
    Book(
      title: 'The Mountain Is You: Transforming Self-Sabotage Into Self-Mastery',
      image: 'assets/images/books/mountain.png',
      price: 261,
      originalPrice: 399,
      author: 'Brianna Wiest',
    ),
    Book(
      title: 'The Power of Your Subconscious Mind',
      image: 'assets/images/books/subconscious.png',
      price: 149,
      originalPrice: 199,
      author: 'Dr. Joseph Murphy',
    ),
    Book(
      title: "World's Greatest Books For Personal Growth & Wealth",
      image: 'assets/images/books/collection.png',
      price: 349,
      originalPrice: 699,
      author: 'Various Authors',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveryLocation();
    _loadNavigationState();
    _loadProducts();
  }

  Future<void> _loadDeliveryLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deliveryLocation = prefs.getString('deliveryLocation') ?? 'Select your location';
    });
  }

  Future<void> _loadNavigationState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('navigationIndex') ?? 0;
    });
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _firestoreService.getProducts();
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    }
  }

  Future<void> _saveNavigationState(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navigationIndex', index);
  }

  Future<void> _updateDeliveryLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deliveryLocation', location);
    setState(() {
      _deliveryLocation = location;
    });
  }

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

  void _onNavigationItemTapped(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, CartView.routeName);
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, OrdersView.routeName);
      return;
    }
    if (index == 1) {
      Navigator.pushNamed(context, ProfileView.routeName);
      return;
    }
    setState(() {
      _selectedIndex = index;
      _saveNavigationState(index);
    });
  }

  void _navigateToProductDetails(Book book) {
    Navigator.pushNamed(
      context,
      ProductDetailsView.routeName,
      arguments: book,
    );
  }

  Widget _buildCategoryItem(String title, String iconPath, bool hasLabel) {
    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              Image.asset(
                iconPath,
                width: 25,
                height: 25,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              if (hasLabel)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      title == 'Prime' ? 'JOIN' : 'FREE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDealItem(Deal deal) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              deal.image,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${deal.discount}% off',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deal.title,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(Book book) {
    return GestureDetector(
      onTap: () => _navigateToProductDetails(book),
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                book.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${book.author}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${book.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${book.originalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.inventory_2_outlined, size: 48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (product.category != null) Text(
                      product.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.search, color: Colors.black54),
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: 'Search or ask a question',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              hintStyle: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showLocationSelectionOverlay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _deliveryLocation,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildCategoryItem('Prime', 'assets/images/icons/prime_icon.png', true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: _bannerImages.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index ? HomeView.orangeColor : Colors.grey[300],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildProductGrid(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Deals for you',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _deals.length,
                itemBuilder: (context, index) {
                  return _buildDealItem(_deals[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pick up where you left off in Books',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  return _buildBookItem(_books[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: HomeView.orangeColor,
        unselectedItemColor: Colors.black54,
        onTap: _onNavigationItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'You',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
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