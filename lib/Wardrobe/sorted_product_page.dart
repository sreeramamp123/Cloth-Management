import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SortedProductPage extends StatelessWidget {
  final String criterion;  // Criterion: 'category', 'color', or 'size'

  const SortedProductPage(this.criterion, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Sorted by $criterion'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products added yet!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Group products by the chosen criterion
          final groupedProducts = _groupProducts(productSnapshot.data!.docs);

          // Display each group as a separate section
          return ListView.builder(
            itemCount: groupedProducts.length,
            itemBuilder: (ctx, index) {
              final groupKey = groupedProducts.keys.elementAt(index);
              final groupProducts = groupedProducts[groupKey];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text('$criterion: $groupKey (${groupProducts?.length} items)'),
                  children: groupProducts!.map((product) {
                    final productData = product.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: const Icon(Icons.checkroom, size: 40),
                      title: Text(productData['name']),
                      subtitle: Text(
                        '${productData['category']} - ${productData['color']} - Size: ${productData['size']}',
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to group products by the chosen criterion
  Map<String, List<DocumentSnapshot>> _groupProducts(List<DocumentSnapshot> products) {
    final Map<String, List<DocumentSnapshot>> groupedProducts = {};

    for (var product in products) {
      final productData = product.data() as Map<String, dynamic>;
      final key = productData[criterion] as String;  // Get the criterion value (category, color, or size)

      if (!groupedProducts.containsKey(key)) {
        groupedProducts[key] = [];
      }
      groupedProducts[key]!.add(product);
    }

    return groupedProducts;
  }
}
