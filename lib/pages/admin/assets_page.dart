import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/admin/widgets/all_assets_page.dart';
import 'package:land_house_verify/pages/admin/widgets/latest_assets_page.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Latest Assets",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Latest Assets Page
             SizedBox(height: 130, child: LatestAssetsPage()),
            const SizedBox(height: 10),
            const Text(
              "All Assets",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // All Assets Page
           Expanded(flex: 3, child: AllAssetsPage()),
          ],
        ),
      ),
    );
  }
}