import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer_validator.dart';
import 'package:land_house_verify/pages/validator/validator_asset_detail.dart';
import 'package:land_house_verify/pages/widget/asset_card_view.dart';

class ValidatorPage extends StatefulWidget {
  final String name;  // Current validator's name

  const ValidatorPage({required this.name, super.key});

  @override
  State<ValidatorPage> createState() => _ValidatorPageState();
}

class _ValidatorPageState extends State<ValidatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawerValidator(),
      appBar: AppBar(
        title: Text('Welcome ${widget.name}'),
      ),
      body: AssetsCard(condition: 'validator', isEqualTo: widget.name , widget: widget,)
        
    );
  }
}
