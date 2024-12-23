import 'package:flutter/material.dart';

class RegisterAssetPage extends StatefulWidget {
  const RegisterAssetPage({super.key});

  @override
  State<RegisterAssetPage> createState() => _RegisterAssetPageState();
}

class _RegisterAssetPageState extends State<RegisterAssetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset '),
      ),
    );
  }
}
