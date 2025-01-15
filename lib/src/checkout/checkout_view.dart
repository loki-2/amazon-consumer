import 'package:flutter/material.dart';
import 'order_success_view.dart';

class CheckoutView extends StatefulWidget {
  static const routeName = '/checkout';
  static const Color orangeColor = Color(0xFFFF9900);

  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _deliveryAddress = 'Flat 42, House No: 3-408/44, Asian Towers,, Hitech Colony, Mancherial, MANCHERIAL, TELANGANA, 504208, India';
  String? _selectedPaymentMethod;

  void _handleContinue() {
    Navigator.pushReplacementNamed(context, OrderSuccessView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select a Payment Method'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivering to ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Abhishek',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _deliveryAddress,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Handle address change
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.blue,
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Change delivery address'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: 'Pay ₹2,026.00 ',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                TextSpan(
                                  text: '₹1,976.00',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' on this order using Amazon Pay Balance. Add ₹500 to avail offer.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Add money'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentOption(
                    'amazonpay',
                    'Amazon Pay UPI',
                    'Available balance: ₹7.00',
                    'Add money & get rewarded',
                    const Icon(Icons.account_balance_wallet, color: Colors.black),
                  ),
                  _buildPaymentOption(
                    'emi',
                    'EMI',
                    null,
                    null,
                    const Icon(Icons.calculate, color: Colors.black),
                  ),
                  _buildPaymentOption(
                    'netbanking',
                    'Net Banking',
                    null,
                    null,
                    const Icon(Icons.account_balance, color: Colors.black),
                  ),
                  _buildPaymentOption(
                    'cod',
                    'Cash on Delivery/Pay on Delivery',
                    'Scan & Pay at delivery with Amazon Pay UPI and get cashback up to ₹10.',
                    'Know more.',
                    const Icon(Icons.payments_outlined, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFED813),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String? subtitle, String? link, Widget icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: _selectedPaymentMethod == value ? const Color(0xFFFFF8E7) : null,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: RadioListTile(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue;
          });
        },
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            icon,
          ],
        ),
        subtitle: subtitle != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (link != null)
                    Text(
                      link,
                      style: const TextStyle(color: Colors.blue),
                    ),
                ],
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        activeColor: Colors.black,
      ),
    );
  }
}