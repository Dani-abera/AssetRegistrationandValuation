import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  String label;
  TextEditingController controller;
  MyTextformfield({required this.controller, required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
