import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteProductPage extends StatefulWidget {
  @override
  _DeleteProductPageState createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  // Function to delete a product from Firestore
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Products'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products in your wardrobe!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = productSnapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final productData = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;  // Get the product ID for deletion

              final productName = productData['product'] ?? 'Unknown Product';
              final productCategory = productData['category'] ?? 'Unknown Category';
              final productColor = productData['color'] ?? 'Unknown Color';
              final productSize = productData['size'] ?? 'Unknown Size';
              final imageUrl = productData['imageUrl'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_not_supported, size: 60),
                  title: Text(productName),
                  subtitle: Text('$productCategory - $productColor - Size: $productSize'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(productId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Show confirmation dialog before deleting the product
  void _showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product from your wardrobe?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();  // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);  // Delete the product
                Navigator.of(ctx).pop();  // Close the dialog after deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
