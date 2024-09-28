import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProductPage extends StatefulWidget {
  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  bool _isSorted = false;
  String _sortCriterion = 'category';  // Default sorting criterion

  // Function to show the sorting dialog
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Category'),
                onTap: () {
                  _applySorting('category');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text('Color'),
                onTap: () {
                  _applySorting('color');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text('Size'),
                onTap: () {
                  _applySorting('size');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to apply sorting based on the selected criterion
  void _applySorting(String criterion) {
    setState(() {
      _isSorted = true;
      _sortCriterion = criterion;
    });
  }

  // Helper function to group products by the selected criterion
  Map<String, List<DocumentSnapshot>> _groupProductsByCriterion(
      List<DocumentSnapshot> products) {
    final Map<String, List<DocumentSnapshot>> groupedProducts = {};

    for (var product in products) {
      final productData = product.data() as Map<String, dynamic>;
      final criterionValue = productData[_sortCriterion] ?? 'Unknown';  // Group by the sorting criterion

      if (!groupedProducts.containsKey(criterionValue)) {
        groupedProducts[criterionValue] = [];
      }
      groupedProducts[criterionValue]!.add(product);
    }

    return groupedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Organised Products'),
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
                'No products added yet!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          var products = productSnapshot.data!.docs;

          // Group products by the selected sorting criterion
          final groupedProducts = _groupProductsByCriterion(products);

          // Display grouped products under headers
          return ListView.builder(
            itemCount: groupedProducts.keys.length,
            itemBuilder: (ctx, index) {
              final groupKey = groupedProducts.keys.elementAt(index);  // Get the criterion group (e.g., category or color)
              final groupItems = groupedProducts[groupKey]!;  // List of products in the group

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(  // Each group has an ExpansionTile
                  title: Text('$groupKey (${groupItems.length} items)'),  // Group header with the criterion value
                  children: groupItems.map((product) {
                    final productData = product.data() as Map<String, dynamic>;

                    final productName = productData['product'] ?? 'Unknown Product';
                    final productCategory = productData['category'] ?? 'Unknown Category';
                    final productColor = productData['color'] ?? 'Unknown Color';
                    final productSize = productData['size'] ?? 'Unknown Size';
                    final imageUrl = productData['imageUrl'];

                    return ListTile(
                      leading: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image_not_supported, size: 60),
                      title: Text(productName),
                      subtitle: Text(
                        '$productCategory - $productColor - Size: $productSize',
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSortDialog,
        child: Icon(Icons.cleaning_services),  // Broom icon
        tooltip: 'Sort Products',
      ),
    );
  }
}
