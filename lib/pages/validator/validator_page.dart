import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer_validator.dart';
import 'package:land_house_verify/pages/validator/notification_page.dart';
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
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage(valuator: widget.name)));
            },
            child: Stack(
              children: [
                Positioned(
                  right: 8, 
                  top: 0,
                  child: Text("1",
                  style: TextStyle(color: Colors.redAccent),
                  )
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications),
                ),
              ],
            ),
          )
       
        ],
      ),
      
      body: AssetsCard(condition: 'validator', isEqualTo: widget.name , widget: widget,)
        
    );
  }
}
