import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer.dart';
import 'package:land_house_verify/pages/admin/assets_page.dart';
import 'package:land_house_verify/pages/admin/register_asset_page.dart';
import 'package:land_house_verify/pages/admin/widgets/all_assets_page.dart';
import 'package:land_house_verify/pages/admin/widgets/latest_assets_page.dart';
import 'package:land_house_verify/pages/authPage/registration_page.dart';

class AdminPage extends StatefulWidget {
  final String name;
  const AdminPage({required this.name, super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Variable to keep track of the selected index
  int _selectedIndex = 0;


  // List of pages to display
  final List<Widget> _pages = [
    const AssetsPage(),
    const RegisterAssetPage(),
    RegisterPage(onTap: () {}),
  ];

  // Function to handle bottom navigation tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Keep track of the selected index
        onTap: _onItemTapped, // Update the index when a tab is tapped
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Asset Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Create Account',
          ),
        ],
      ),
    );
  
  }
}
