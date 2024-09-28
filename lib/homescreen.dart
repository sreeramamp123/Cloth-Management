import 'package:cloth/Community%20Exchange/community_exchange.dart';
import 'package:cloth/Dashboard/analytics_dashboard.dart';
import 'package:cloth/Wardrobe/wardrobe_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens (can be separate widgets for each tab)
  final List<Widget> _screens = <Widget>[
    const WardrobeScreen(),
    CommunityExchangePage(),
    const AnalyticsDashboard(), // Replace Style Inspiration with AnalyticsDashboard
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: "Wardrobe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Community Exchange',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Change icon for Analytics
            label: 'Analytics', // Replace Style Inspiration with Analytics
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // Switch between tabs
      ),
    );
  }
}
