import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer.dart';
import 'package:land_house_verify/pages/admin/widgets/all_assets_page.dart';
import 'package:land_house_verify/pages/admin/widgets/latest_assets_page.dart';
import 'package:land_house_verify/pages/admin/widgets/search_asset.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  bool _isNotSearching = true;
  // Variable to store the search query
  String _searchQuery = "";

  // Function to handle search query change
  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: _isNotSearching
            ? Text(
                'Welcome',
                style: const TextStyle(color: Colors.black),
              )
            : Container(
                margin: const EdgeInsets.only(top: 10),
                height: 40,
                width: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: TextFormField(
                  onChanged: _onSearchQueryChanged, // Handle query change
                  decoration: InputDecoration(
                    hintText: 'Search registered assets',
                    hintStyle:
                        TextStyle(color: Theme.of(context).disabledColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isNotSearching = false;
                    });
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Latest Assets",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Latest Assets Page
            SizedBox(height: 200, child: LatestAssetsPage()),
            const SizedBox(height: 10),
            const Text(
              "All Registered Assets",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // All Assets Page
            _isNotSearching
                ? Expanded(flex: 3, child: AllAssetsPage())
                : SearchAsset(searchQuery: _searchQuery),
          ],
        ),
      ),
    );
  }
}
