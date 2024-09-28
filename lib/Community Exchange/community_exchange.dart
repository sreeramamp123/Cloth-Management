import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityExchangePage extends StatefulWidget {
  @override
  _CommunityExchangePageState createState() => _CommunityExchangePageState();
}

class _CommunityExchangePageState extends State<CommunityExchangePage> {
  bool _isViewingTrade = true;  // Toggle between viewing Trade or Donate items

  // Toggle between Trade and Donate views
  void _toggleView() {
    setState(() {
      _isViewingTrade = !_isViewingTrade;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isViewingTrade ? 'Items Available for Trade' : 'Items Available for Donation'),
        actions: [
          IconButton(
            icon: Icon(_isViewingTrade ? Icons.swap_horiz : Icons.volunteer_activism),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where(_isViewingTrade ? 'isAvailableForTrade' : 'isAvailableForDonate', isEqualTo: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No items available!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = productSnapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final productData = products[index].data() as Map<String, dynamic>;

              final productName = productData['product'] ?? 'Unknown Product';
              final productCategory = productData['category'] ?? 'Unknown Category';
              final productColor = productData['color'] ?? 'Unknown Color';
              final productSize = productData['size'] ?? 'Unknown Size';
              final imageUrl = productData['imageUrl'];

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image_not_supported, size: 150),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        productName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('$productCategory - $productColor - Size: $productSize'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
