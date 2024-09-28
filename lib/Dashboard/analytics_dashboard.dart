import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // For formatting dates

class AnalyticsDashboard extends StatefulWidget {

  const AnalyticsDashboard({super.key});

  @override
  _AnalyticsDashboardState createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  // Function to calculate days since last worn
  int _daysSinceLastWorn(List<dynamic> wearEvents) {
    if (wearEvents.isEmpty) return -1;  // If never worn, return -1

    final lastWornDate = (wearEvents.last as Timestamp).toDate();
    final now = DateTime.now();
    return now.difference(lastWornDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
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
                'No products to track!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final products = productSnapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final productData = products[index].data() as Map<String, dynamic>;

              final productName = productData['product'] ?? 'Unknown Product';
              final productCategory = productData['category'] ?? 'Unknown Category';
              final wearEvents = productData['wearEvents'] ?? [];

              // How many times the item has been worn
              final wearCount = wearEvents.length;

              // Days since last worn
              final daysSinceLastWorn = _daysSinceLastWorn(wearEvents);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: ListTile(
                  title: Text(productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: $productCategory'),
                      Text('Worn $wearCount times'),
                      if (daysSinceLastWorn != -1)
                        Text('Last worn: $daysSinceLastWorn days ago'),
                      if (daysSinceLastWorn == -1)
                        Text('Never worn'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
