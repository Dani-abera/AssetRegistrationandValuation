import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer_validator.dart';

class ValidatorPage extends StatefulWidget {
  String name;
  ValidatorPage({required this.name, super.key});

  @override
  State<ValidatorPage> createState() => _ValidatorPageState();
}

class _ValidatorPageState extends State<ValidatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawerValidator(),
      appBar: AppBar(
        title: Text('Welcome To Validator Page${widget.name}'),
      ),
    );
  }
}
