// ignore_for_file: file_names

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextformfield extends StatelessWidget {
  String label;
  TextEditingController controller;
  int? length;
  MyTextformfield({
    required this.controller,
    required this.label,
    super.key,
    this.length,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        maxLines: length,
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
