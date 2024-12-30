import 'package:flutter/material.dart';

class ValuationReport extends StatelessWidget {
  const ValuationReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListTile(
            title: Text("Jemo Michael ValuationReport"),
            trailing: Row(children: [
              Text("View", style: TextStyle(color: Colors.blue),),
              Text("download",style: TextStyle(color: Colors.blue),)
            ],),
        ),
      ),
    );
  }
}