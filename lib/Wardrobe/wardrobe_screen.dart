import 'package:flutter/material.dart';
import 'add_product.dart';
import 'view_product.dart';
import 'delete_product.dart';  // Import DeleteProductPage

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wardrobe'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,  // Center buttons vertically
        crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretch buttons to full width
        children: [
          // Add Product, View Organized Products, and Remove Products Buttons in a Column
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
              child: Text('Add Product'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ViewProductPage()),
                );
              },
              child: Text('View Organized Products'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DeleteProductPage()),
                );
              },
              child: Text('Remove Products'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
