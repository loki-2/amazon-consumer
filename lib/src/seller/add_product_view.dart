import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductView extends StatefulWidget {
  static const routeName = '/seller/add-product';
  static const Color orangeColor = Color(0xFFFF9900);

  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isLimitedTimeDeal = false;
  bool _isEligibleForFreeShipping = false;
  final Map<String, TextEditingController> _specificationControllers = {
    'Color': TextEditingController(),
    'Size': TextEditingController(),
    'Material': TextEditingController(),
    'Weight': TextEditingController(),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    for (var controller in _specificationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleAddProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final productsList = prefs.getStringList('products') ?? [];
        
        // Create product data
        final productData = {
          'title': _titleController.text,
          'brand': _brandController.text,
          'price': _priceController.text,
          'mrp': _mrpController.text,
          'description': _descriptionController.text,
          'isLimitedTimeDeal': _isLimitedTimeDeal.toString(),
          'isEligibleForFreeShipping': _isEligibleForFreeShipping.toString(),
          'discount': _isLimitedTimeDeal ? _discountController.text : '0',
          'specifications': _specificationControllers.map((key, value) => 
            MapEntry(key, value.text)).toString(),
        }.toString();

        productsList.add(productData);
        await prefs.setStringList('products', productsList);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brand name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mrpController,
                      decoration: const InputDecoration(
                        labelText: 'MRP',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MRP';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Limited Time Deal'),
                value: _isLimitedTimeDeal,
                onChanged: (bool value) {
                  setState(() {
                    _isLimitedTimeDeal = value;
                  });
                },
              ),
              if (_isLimitedTimeDeal)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount Percentage',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_isLimitedTimeDeal && (value == null || value.isEmpty)) {
                        return 'Please enter discount percentage';
                      }
                      return null;
                    },
                  ),
                ),
              SwitchListTile(
                title: const Text('Eligible for Free Shipping'),
                value: _isEligibleForFreeShipping,
                onChanged: (bool value) {
                  setState(() {
                    _isEligibleForFreeShipping = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._specificationControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAddProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AddProductView.orangeColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add Product',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}